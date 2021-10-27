import { Component, OnInit } from '@angular/core';
import { ModesService } from './modes.service';
import { Mode } from './mode';
import { ModeType } from './mode-type';
import { ModeUpdate } from './mode-update.model';
import { MatDialog } from '@angular/material/dialog';
import { DeleteModeConfirmationDialog } from './delete-mode-confirmation-dialog.component';
import { Router, ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { Observable } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';
import { RxwebValidators, NumericValueType } from "@rxweb/reactive-form-validators";
import { UniqueModeNameValidator } from './unique-mode-name.validator';
import { map } from 'rxjs/operators';

@Component({
  selector: 'mode',
  template: `
<div *ngIf="modeForm">
  <h1>{{name.value}}</h1>
  <form id="mode-form" [formGroup]="modeForm" (ngSubmit)="onSubmit()">
    <mat-label>{{modeType.name}}</mat-label><br>
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
  </form>
  <button mat-raised-button type="submit" form="mode-form" color="primary" (click)="onSubmit()">Save</button>
  <button mat-raised-button color="primary" (click)="onUse()">Use</button>
  <button mat-raised-button color="primary" (click)="onDelete()">Delete</button>
  <button mat-raised-button color="primary" (click)="onAll()">All Modes</button>
</div>
`
})
export class ModeComponent implements OnInit {
  modeForm: FormGroup | undefined = undefined;
  modeId$: Observable<number>;
  mode: Mode | undefined = undefined;

  constructor(private readonly formBuilder: FormBuilder,
	      private readonly modesService: ModesService,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly dialog: MatDialog,
	      private readonly activatedRoute: ActivatedRoute,
	      private readonly uniqueModeNameValidator: UniqueModeNameValidator) {
    this.modeId$ = this.activatedRoute.params.pipe(map(p => p.modeId));
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get name() {
    return this.modeForm?.get('name');
  }

  get modeType(): ModeType | undefined {
    return this.mode?.modeType;
  } 

  get hasBuffer() {
    return !!this.modeType?.buffers?.length;
  }

  get buffer() {
    return this.modeForm?.get('buffer')!;
  }
  
  get cubeSize() {
    return this.modeForm?.get('cubeSize')!;
  }
  
  get showInputMode() {
    return this.modeForm?.get('showInputMode')!;
  }
  
  get goalBadness() {
    return this.modeForm?.get('goalBadness')!;
  }
  
  get known() {
    return this.modeForm?.get('known')!;
  }

  onAll() {
    this.router.navigate([`/modes`]);
  }

  onDelete() {
    const dialogRef = this.dialog.open(DeleteModeConfirmationDialog, { data: this.mode });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
	this.modesService.destroy(this.mode!.id).subscribe(() => {
	  this.snackBar.open(`Mode ${this.mode!.name} deleted!`, 'Close');
	  this.router.navigate([`/modes`]);
	});
      }
    });
  }

  onSubmit() {
    this.modesService.update(this.mode!.id, this.modeUpdate).subscribe(
      r => {
	this.snackBar.open(`Mode ${this.modeUpdate.name} Updated!`, 'Close');
	this.router.navigate([`/modes`]);
      });
  }

  onUse() {
    this.router.navigate([`/trainer/${this.mode!.id}`]);
  }

  get modeUpdate(): ModeUpdate {
    return {
      name: 'name',
      statTypes: [],
      known: !!this.known.value,
      showInputMode: this.showInputMode.value,
    };
  }

  createModeForm(mode: Mode) {
    // TODO: Unify this with new-mode.component.ts
    return this.formBuilder.group({
      name: [mode.name, { validators: Validators.required, asyncValidators: this.uniqueModeNameValidator.validate, updateOn: 'blur' }],
      cubeSize: [mode.cubeSize, Validators.required],
      buffer: [mode.buffer, Validators.required],
      showInputMode: [
	mode.showInputMode || '',
	Validators.required
      ],
      goalBadness: [
	mode.goalBadness || '',
	(mode.modeType.hasGoalBadness ? [Validators.required, RxwebValidators.numeric({ acceptValue: NumericValueType.PositiveNumber, allowDecimal: true })] : [])
      ],
      known: [mode.known || ''],
    });
  }

  ngOnInit() {
    this.modeId$.subscribe(modeId => {
      this.modesService.show(modeId).subscribe((mode: Mode) => {
	this.mode = mode;
	this.modeForm = this.createModeForm(mode);
      });
    });
  }
}
