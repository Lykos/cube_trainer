import { Injectable } from '@angular/core';
import { UniqueModeNameValidator } from './unique-mode-name.validator';
import { ModeType } from './mode-type.model';
import { RxwebValidators, NumericValueType } from "@rxweb/reactive-form-validators";
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

function hasMultipleCubeSizes(modeType: ModeType | undefined) {
  const cubeSizeSpec = modeType?.cubeSizeSpec;
  return cubeSizeSpec && cubeSizeSpec.min < cubeSizeSpec.max;
}

function minCubeSize(modeType: ModeType | undefined) {
  return modeType?.cubeSizeSpec?.min;
}

function maxCubeSize(modeType: ModeType | undefined) {
  return modeType?.cubeSizeSpec?.max;
}

function hasBuffer(modeType: ModeType | undefined) {
  return !!modeType?.buffers?.length;
}

function hasMultipleShowInputModes(modeType: ModeType | undefined) {
  return modeType && modeType.showInputModes.length > 1;
}

function allowsOnlyOddCubeSizes(modeType: ModeType | undefined) {
  const cubeSizeSpec = modeType?.cubeSizeSpec;
  return cubeSizeSpec && !cubeSizeSpec.evenAllowed;
}

function allowsOnlyEvenCubeSizes(modeType: ModeType | undefined) {
  const cubeSizeSpec = modeType?.cubeSizeSpec;
  return cubeSizeSpec && !cubeSizeSpec.oddAllowed;
}

function minCubeSizeValidator(modeTypeProvider: () => ModeType | undefined, value: number) {
  return RxwebValidators.minNumber({ conditionalExpression: () => minCubeSize(modeTypeProvider()) === value, value });
}

function maxCubeSizeValidator(modeTypeProvider: () => ModeType | undefined, value: number) {
  return RxwebValidators.maxNumber({ conditionalExpression: () => maxCubeSize(modeTypeProvider()) === value, value });
}

function cubeSizeValidators(modeTypeProvider: () => ModeType | undefined) {
  const validators = [
    RxwebValidators.required(),
    RxwebValidators.digit(),
    // If this mode only allows odd cube sizes, validate that.
    RxwebValidators.odd({ conditionalExpression: () => allowsOnlyOddCubeSizes(modeTypeProvider()) }),
    // If this mode only allows odd cube sizes, validate that.
    RxwebValidators.even({ conditionalExpression: () => allowsOnlyEvenCubeSizes(modeTypeProvider()) }),
    // Always restrict the cube size to be between 2 and 7.
    RxwebValidators.minNumber({ value: 2 }),
    RxwebValidators.maxNumber({ value: 7 }),
    // For modes that have a minimum cube size of 7 or a maximum cube size of 2, add the conditional validators.
    minCubeSizeValidator(modeTypeProvider, 7),
    maxCubeSizeValidator(modeTypeProvider, 2),
  ];
  // For all possible cube sizes between 3 and 6, add conditional validators for minimum and maximum cube sizes.
  for (var i = 3; i <= 6; ++i) {
    validators.push(minCubeSizeValidator(modeTypeProvider, i));
    validators.push(maxCubeSizeValidator(modeTypeProvider, i));
  }
  return validators;
}


@Injectable({
  providedIn: 'root'
})
export class ModeFormsService {
  constructor(private readonly formBuilder: FormBuilder,
              private readonly uniqueModeNameValidator: UniqueModeNameValidator) {}

  modeTypeGroup(): FormGroup {
    return this.formBuilder.group({
      name: ['', { validators: Validators.required, asyncValidators: this.uniqueModeNameValidator.validate, updateOn: 'blur' }],
      modeType: ['', Validators.required],
    });
  }

  algSetGroup(modeTypeProvider: () => ModeType | undefined): FormGroup {
    return this.formBuilder.group({
      algSet: [''],
    });
  }

  setupGroup(modeTypeProvider: () => ModeType | undefined): FormGroup {
    return this.formBuilder.group({
      cubeSize: ['', RxwebValidators.compose({
	conditionalExpression: () => hasMultipleCubeSizes(modeTypeProvider()),
	validators: cubeSizeValidators(modeTypeProvider),
      })],
      buffer: ['', RxwebValidators.required({ conditionalExpression: () => hasBuffer(modeTypeProvider()) })],
    });
  }

  trainingGroup(modeTypeProvider: () => ModeType | undefined): FormGroup {
    return this.formBuilder.group({
      showInputMode: ['', RxwebValidators.required({ conditionalExpression: () => hasMultipleShowInputModes(modeTypeProvider()) })],
      goalBadness: ['', RxwebValidators.compose({
	conditionalExpression: () => modeTypeProvider()?.hasGoalBadness,
	validators: [
	  RxwebValidators.required(),
	  RxwebValidators.numeric({ acceptValue: NumericValueType.PositiveNumber, allowDecimal: true })
	],
      })],
      memoTimeS: ['', RxwebValidators.compose({
	conditionalExpression: () => modeTypeProvider()?.hasMemoTime,
	validators: [
	  RxwebValidators.required(),
	  RxwebValidators.numeric({ acceptValue: NumericValueType.PositiveNumber, allowDecimal: true })
	],
      })],
      known: ['']
    });
  }
}
