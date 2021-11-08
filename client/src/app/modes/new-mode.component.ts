import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { UniqueModeNameValidator } from './unique-mode-name.validator';
import { ModeType } from './mode-type';
import { ModesService } from './modes.service';
import { NewMode } from './new-mode';
import { StatType } from './stat-type';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { RxwebValidators, NumericValueType } from "@rxweb/reactive-form-validators";
import { CdkDragDrop, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';

@Component({
  selector: 'cube-trainer-new-mode',
  templateUrl: './new-mode.component.html',
  styleUrls: ['./new-mode.component.css']
})
export class NewModeComponent implements OnInit {
  modeTypeGroup!: FormGroup;
  setupGroup!: FormGroup;
  trainingGroup!: FormGroup;
  modeTypes!: ModeType[];
  pickedStatTypes: StatType[] = [];

  lastModeTypeForStatsTypes: ModeType | undefined
  statTypesForLastModeType: StatType[] = [];
  
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

  get statTypesForCurrentModeType() {
    if (this.lastModeTypeForStatsTypes !== this.modeType.value) {
      this.statTypesForLastModeType = Object.assign([], this.modeType.value!.statsTypes);
      this.lastModeTypeForStatsTypes = this.modeType.value;
    }
    return this.statTypesForLastModeType;
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

  get memoTimeS() {
    return this.trainingGroup.get('memoTimeS')!;
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

  get hasMemoTime() {
    return this.modeType.value?.hasMemoTime;
  }

  get hasBoundedInputs() {
    return this.modeType.value?.hasBoundedInputs;
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

  get selectedCubeSize(): number | undefined {
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
      known: !!this.trainingGroup.get('known')?.value,
      showInputMode: this.selectedShowInputMode,
      buffer: this.buffer.value,
      goalBadness: this.goalBadness.value,
      memoTimeS: this.memoTimeS.value,
      cubeSize: this.selectedCubeSize,
      statTypes: this.pickedStatTypes.map(s => s.key),
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
      memoTimeS: ['', RxwebValidators.compose({
	conditionalExpression: () => this.hasMemoTime,
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
	this.snackBar.open(`Mode ${this.newMode.name} Created!`, 'Close');
	this.router.navigate([`/modes`]);
      });
  }

  drop(event: CdkDragDrop<StatType[]>) {
    if (event.previousContainer === event.container) {
      moveItemInArray(event.container.data, event.previousIndex, event.currentIndex);
    } else {
      transferArrayItem(event.previousContainer.data,
                        event.container.data,
                        event.previousIndex,
                        event.currentIndex);
    }
  }
}
