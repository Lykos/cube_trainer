import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { UniqueModeNameValidator } from './unique-mode-name.validator';
import { ModeType } from './mode-type';
import { ModesService } from './modes.service';
import { NewMode } from './new-mode';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { RxwebValidators, NumericValueType } from "@rxweb/reactive-form-validators";

@Component({
  selector: 'edit-mode',
  template: `
<mat-horizontal-stepper linear #stepper>
  <mat-step [stepControl]="modeTypeGroup">
    <ng-template matStepLabel>Choose mode type</ng-template>
    <form [formGroup]="modeTypeGroup">
      <mat-form-field>
        <mat-label>Name</mat-label>
        <input matInput formControlName="name" type="text">
        <mat-error *ngIf="relevantInvalid(name) && name.errors.required">
          You must provide a <strong>name</strong>.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(name) && name.errors.uniqueModeName">
          You already have a mode with the same <strong>name</strong>.
        </mat-error>
      </mat-form-field>
      <mat-form-field>
        <mat-label>Mode Type</mat-label>
        <mat-select formControlName="modeType">
          <mat-option *ngFor="let modeType of modeTypes" [value]="modeType"> {{modeType.name}} </mat-option>
        </mat-select>
        <mat-error *ngIf="relevantInvalid(modeType) && modeType.errors.required">
          You must provide a <strong>mode type</strong>.
        </mat-error>
      </mat-form-field>
      <div>
        <button mat-raised-button color="primary" matStepperNext>Next</button>
      </div>
    </form>
  </mat-step>
  <mat-step [stepControl]="setupGroup">
    <ng-template matStepLabel>Setup basics</ng-template>
    <form [formGroup]="setupGroup">
      <mat-form-field *ngIf="hasMultipleCubeSizes">
        <mat-label>Cube Size</mat-label>
        <input matInput formControlName="cubeSize" type="number" [value]="defaultCubeSize">
        <mat-error *ngIf="relevantInvalid(cubeSize) && cubeSize.errors.required">
          You must provide a <strong>cube size</strong> for this mode type.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(cubeSize) && cubeSize.errors.minNumber">
          The <strong>cube size</strong> has to be at least {{minCubeSize}} for this mode type.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(cubeSize) && cubeSize.errors.maxNumber">
          The <strong>cube size</strong> can be at most {{maxCubeSize}} for this mode type.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(cubeSize) && cubeSize.errors.odd">
          The <strong>cube size</strong> has to be odd for this cube size.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(cubeSize) && cubeSize.errors.even">
          The <strong>cube size</strong> has to be even for this cube size.
        </mat-error>
      </mat-form-field>
      <mat-form-field *ngIf="hasBuffer">
        <mat-label>Buffer</mat-label>
        <mat-select formControlName="buffer">
          <mat-option *ngFor="let buffer of modeType.value.buffers" [value]="buffer"> {{buffer}} </mat-option>
        </mat-select>
        <mat-error *ngIf="relevantInvalid(buffer) && buffer.errors.required">
          You must provide a <strong>buffer</strong> for this mode type.
        </mat-error>
      </mat-form-field>
      <div>
        <button mat-raised-button color="primary" matStepperPrevious>Back</button>
        <button mat-raised-button color="primary" matStepperNext>Next</button>
      </div>
    </form>
  </mat-step>
  <mat-step [stepControl]="trainingGroup">
    <ng-template matStepLabel>Set training information</ng-template>
    <form [formGroup]="trainingGroup">
      <mat-form-field *ngIf="hasMultipleShowInputModes">
        <mat-label>show input mode</mat-label>
        <mat-select formControlName="showInputMode">
          <mat-option *ngFor="let showInputMode of modeType.value.showInputModes" [value]="showInputMode"> {{showInputMode}} </mat-option>
        </mat-select>
        <mat-error *ngIf="relevantInvalid(showInputMode) && showInputMode.errors.required">
          You must select a <strong>show input mode</strong> for this mode type.
        </mat-error>
      </mat-form-field>
      <mat-form-field *ngIf="hasGoalBadness">
        <mat-label>Goal Time per Element</mat-label>
        <input matInput formControlName="goalBadness" type="number">
        <mat-error *ngIf="relevantInvalid(goalBadness) && goalBadness.errors.required">
          You must provide a <strong>goal badness</strong> for this mode type.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(goalBadness) && goalBadness.errors.numeric">
          The <strong>goal badness</strong> has to be a positive number.
        </mat-error>
      </mat-form-field>
      <mat-checkbox formControlName="known">Known</mat-checkbox>
      <div>
        <button mat-raised-button color="primary" matStepperPrevious>Back</button>
        <button mat-raised-button color="primary" (click)="onSubmit()">Submit</button>
      </div>
    </form>
  </mat-step>
</mat-horizontal-stepper>
`,
})
export class NewModeComponent implements OnInit {
  modeTypeGroup!: FormGroup;
  setupGroup!: FormGroup;
  trainingGroup!: FormGroup;
  modeTypes!: ModeType[];
  
  constructor(private readonly formBuilder: FormBuilder,
	      private readonly modesService: ModesService,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly uniqueModeNameValidator: UniqueModeNameValidator) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get name() {
    return this.modeTypeGroup.get('name')!;
  }

  get hasMultipleShowInputModes() {
    return this.modeType.value && this.modeType.value.showInputModes.length > 1;
  }

  get cubeSize() {
    return this.setupGroup.get('cubeSize')!;
  }

  get buffer() {
    return this.setupGroup.get('buffer')!;
  }

  get goalBadness() {
    return this.trainingGroup.get('goalBadness')!;
  }

  get showInputMode() {
    return this.trainingGroup.get('showInputMode')!;
  }

  get hasMultipleCubeSizes() {
    return this.modeType.value?.cubeSizeSpec && this.minCubeSize < this.maxCubeSize;
  }

  get hasBuffer() {
    return !!this.modeType.value?.buffers?.length;
  }

  get hasGoalBadness() {
    return this.modeType.value?.hasGoalBadness;
  }

  get defaultCubeSize() {
    return this.modeType.value?.cubeSizeSpec?.default;
  }

  get minCubeSize() {
    return this.modeType.value?.cubeSizeSpec?.min;
  }

  get maxCubeSize() {
    return this.modeType.value?.cubeSizeSpec?.max;
  }

  get oddAllowed() {
    return this.modeType.value?.cubeSizeSpec?.oddAllowed;
  }

  get evenAllowed() {
    return this.modeType.value?.cubeSizeSpec?.evenAllowed;
  }

  get modeType() {
    return this.modeTypeGroup.get('modeType')!;
  }

  get selectedShowInputMode() {
    if (this.modeType.value && this.modeType.value.showInputModes.length == 1) {
      return this.modeType.value.showInputModes[0];
    } else if (this.hasMultipleShowInputModes) {
      return this.showInputMode.value;
    } else {
      return undefined;
    }
  }

  get selectedCubeSize() {
    if (this.hasMultipleCubeSizes) {
      return this.cubeSize.value;
    } else {
      return this.defaultCubeSize;
    }
  }

  get newMode(): NewMode {
    return {
      modeType: this.modeType.value!.key,
      name: this.name.value,
      known: !!this.trainingGroup.get('known')!.value,
      showInputMode: this.selectedShowInputMode,
      buffer: this.buffer.value,
      goalBadness: this.goalBadness.value,
      cubeSize: this.cubeSize.value,
    };
  }

  minCubeSizeValidator(value: number) {
    return RxwebValidators.minNumber({ conditionalExpression: () => this.minCubeSize === value, value });
  }

  maxCubeSizeValidator(value: number) {
    return RxwebValidators.maxNumber({ conditionalExpression: () => this.maxCubeSize === value, value });
  }

  cubeSizeValidators() {
    const validators = [
      RxwebValidators.minNumber({ value: 2 }),
      RxwebValidators.maxNumber({ value: 7 }),
      this.minCubeSizeValidator(7),
      this.maxCubeSizeValidator(2),
    ];
    for (var i = 3; i <= 6; ++i) {
      validators.push(this.minCubeSizeValidator(i));
      validators.push(this.maxCubeSizeValidator(i));
    }
    return validators;
  }

  ngOnInit() {
    this.modesService.listTypes().subscribe((modeTypes: ModeType[]) => this.modeTypes = modeTypes);
    this.modeTypeGroup = this.formBuilder.group({
      name: ['', { validators: Validators.required, asyncValidators: this.uniqueModeNameValidator.validate, updateOn: 'blur' }],
      modeType: ['', Validators.required],
    });
    this.setupGroup = this.formBuilder.group({
      cubeSize: ['', RxwebValidators.compose({
	conditionalExpression: () => this.hasMultipleCubeSizes,
	validators: [
	  RxwebValidators.required(),
	  RxwebValidators.digit(),
	  RxwebValidators.odd({ conditionalExpression: () => !this.evenAllowed }),
	  RxwebValidators.even({ conditionalExpression: () => !this.oddAllowed }),
	].concat(this.cubeSizeValidators()),
      })],
      buffer: ['', RxwebValidators.required({ conditionalExpression: () => this.hasBuffer })],
    });
    this.trainingGroup = this.formBuilder.group({
      showInputMode: ['', RxwebValidators.required({ conditionalExpression: () => this.hasMultipleShowInputModes })],
      goalBadness: ['', RxwebValidators.compose({
	conditionalExpression: () => this.hasGoalBadness,
	validators: [
	  RxwebValidators.required(),
	  RxwebValidators.numeric({ acceptValue: NumericValueType.PositiveNumber, allowDecimal: true })
	],
      })],
      known: ['']
    });
  }

  onSubmit() {
    this.modesService.create(this.newMode).subscribe(
      r => {
	this.snackBar.open('Mode Created!', 'Close');
	this.router.navigate([`/modes`]);
      });
  }
}
