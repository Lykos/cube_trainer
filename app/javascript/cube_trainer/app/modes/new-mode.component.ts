import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { UniqueModeNameValidator } from './unique-mode-name.validator';
import { ModeType } from './mode-type';
import { ModesService } from './modes.service';
import { NewMode } from './new-mode';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { RxwebValidators } from "@rxweb/reactive-form-validators";

@Component({
  selector: 'edit-mode',
  template: `
<mat-horizontal-stepper linear #stepper>
  <mat-step [stepControl]="modeTypesGroup">
    <ng-template matStepLabel>Choose mode type</ng-template>
    <form [formGroup]="modeTypesGroup">
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
      <mat-form-field *ngIf="hasCubeSize">
        <mat-label>Cube Size</mat-label>
        <input matInput formControlName="cubeSize" type="number">
        <mat-error *ngIf="relevantInvalid(cubeSize) && cubeSize.errors.required">
          You must provide a <strong>cube size</strong> for this mode type.
        </mat-error>
      </mat-form-field>
      <mat-form-field *ngIf="hasBuffer">
        <mat-label>Buffer</mat-label>
        <mat-select formControlName="buffer">
          <mat-option *ngFor="let buffer of modeType.buffers" [value]="buffer"> {{buffer}} </mat-option>
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
          <mat-option *ngFor="let showInputMode of modeType.showInputModes" [value]="showInputMode"> {{showInputMode}} </mat-option>
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
  modeTypesGroup!: FormGroup;
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
    return this.modeTypesGroup.get('name')!;
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
    return this.setupGroup.get('goalBadness')!;
  }

  get hasCubeSize() {
    return this.modeType.value && this.modeType.value.defaultCubeSize;
  }

  get hasBuffer() {
    return this.modeType.value?.hasBuffer;
  }

  get hasGoalBadness() {
    return this.modeType.value?.hasGoalBadness;
  }

  get modeType() {
    return this.modeTypesGroup.get('modeType')!;
  }

  get selectedShowInputMode() {
    if (this.modeType.value && this.modeType.value.showInputModes.length == 1) {
      return this.modeType.value.showInputModes[0];
    } else if (this.hasMultipleShowInputModes) {
      return this.trainingGroup.get('showInputMode')!.value;
    } else {
      return undefined;
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

  ngOnInit() {
    this.modesService.listTypes().subscribe((modeTypes: ModeType[]) => this.modeTypes = modeTypes);
    this.modeTypesGroup = this.formBuilder.group({
      name: ['', { validators: Validators.required, asyncValidators: this.uniqueModeNameValidator.validate, updateOn: 'blur' }],
      modeType: ['', Validators.required],
    });
    this.setupGroup = this.formBuilder.group({
      cubeSize: ['', RxwebValidators.required({ conditionalExpression: () => this.hasCubeSize })],
      buffer: ['', RxwebValidators.required({ conditionalExpression: () => this.hasBuffer })],
    });
    this.trainingGroup = this.formBuilder.group({
      showInputMode: ['', RxwebValidators.required({ conditionalExpression: () => this.hasMultipleShowInputModes })],
      goalBadness: ['', RxwebValidators.required({ conditionalExpression: () => this.hasGoalBadness })],
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
