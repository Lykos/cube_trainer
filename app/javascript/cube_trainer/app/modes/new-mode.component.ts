import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { ModeType } from './mode-type';
import { ModesService } from './modes.service';
import { NewMode } from './new-mode';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';

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
      </mat-form-field>
      <mat-form-field>
        <mat-label>Mode Type</mat-label>
        <mat-select formControlName="modeType">
          <mat-option *ngFor="let modeType of modeTypes" [value]="modeType"> {{modeType.name}} </mat-option>
        </mat-select>
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
      </mat-form-field>
      <mat-form-field *ngIf="hasBuffer">
        <mat-label>Buffer</mat-label>
        <mat-select formControlName="buffer">
          <mat-option *ngFor="let buffer of modeType.buffers" [value]="buffer"> {{buffer}} </mat-option>
        </mat-select>
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
      </mat-form-field>
      <mat-form-field *ngIf="hasGoalBadness">
        <mat-label>Goal Time per Element</mat-label>
        <input matInput formControlName="goalBadness" type="number">
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
	      private readonly snackBar: MatSnackBar) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get hasMultipleShowInputModes() {
    return this.modeType && this.modeType.showInputModes.length > 1;
  }

  get hasCubeSize() {
    return this.modeType && this.modeType.defaultCubeSize;
  }

  get hasBuffer() {
    return this.modeType?.hasBuffer;
  }

  get hasGoalBadness() {
    return this.modeType?.hasGoalBadness;
  }

  get modeType() {
    return this.modeTypesGroup.get('modeType')?.value;
  }

  get mode(): NewMode {
    return {
      modeType: this.modeType!.key,
      name: this.modeTypesGroup.get('name')!.value,
      known: !!this.trainingGroup.get('known')!.value,
      showInputMode: this.trainingGroup.get('showInputMode')!.value,
      buffer: this.setupGroup.get('buffer')!.value,
      goalBadness: this.trainingGroup.get('goalBadness')!.value,
      cubeSize: this.setupGroup.get('cubeSize')!.value,
    };
  }

  ngOnInit() {
    // TODO Smart form validators depending on the situation.
    this.modesService.listTypes().subscribe((modeTypes: ModeType[]) => this.modeTypes = modeTypes);
    this.modeTypesGroup = this.formBuilder.group({
      name: ['', Validators.required],
      modeType: ['', Validators.required],
    });
    this.setupGroup = this.formBuilder.group({
      cubeSize: [''],
      buffer: [''],
    });
    this.trainingGroup = this.formBuilder.group({
      showInputMode: ['', Validators.required],
      goalBadness: ['', Validators.required],
      known: ['', Validators.required],
    });
  }

  onSubmit() {
    this.modesService.create(this.mode).subscribe(
      r => {
	this.snackBar.open('Mode Created!', 'Close');
	this.router.navigate([`/modes`]);
      });
  }
}
