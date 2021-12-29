import { Injectable } from '@angular/core';
import { UniqueTrainingSessionNameValidator } from './unique-training-session-name.validator';
import { TrainingSessionType } from './training-session-type.model';
import { RxwebValidators, NumericValueType } from "@rxweb/reactive-form-validators";
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

function hasMultipleCubeSizes(trainingSessionType: TrainingSessionType | undefined) {
  const cubeSizeSpec = trainingSessionType?.cubeSizeSpec;
  return cubeSizeSpec && cubeSizeSpec.min < cubeSizeSpec.max;
}

function minCubeSize(trainingSessionType: TrainingSessionType | undefined) {
  return trainingSessionType?.cubeSizeSpec?.min;
}

function maxCubeSize(trainingSessionType: TrainingSessionType | undefined) {
  return trainingSessionType?.cubeSizeSpec?.max;
}

function hasBuffer(trainingSessionType: TrainingSessionType | undefined) {
  return !!trainingSessionType?.buffers?.length;
}

function hasMultipleShowInputModes(trainingSessionType: TrainingSessionType | undefined) {
  return trainingSessionType && trainingSessionType.showInputModes.length > 1;
}

function allowsOnlyOddCubeSizes(trainingSessionType: TrainingSessionType | undefined) {
  const cubeSizeSpec = trainingSessionType?.cubeSizeSpec;
  return cubeSizeSpec && !cubeSizeSpec.evenAllowed;
}

function allowsOnlyEvenCubeSizes(trainingSessionType: TrainingSessionType | undefined) {
  const cubeSizeSpec = trainingSessionType?.cubeSizeSpec;
  return cubeSizeSpec && !cubeSizeSpec.oddAllowed;
}

function minCubeSizeValidator(trainingSessionTypeProvider: () => TrainingSessionType | undefined, value: number) {
  return RxwebValidators.minNumber({ conditionalExpression: () => minCubeSize(trainingSessionTypeProvider()) === value, value });
}

function maxCubeSizeValidator(trainingSessionTypeProvider: () => TrainingSessionType | undefined, value: number) {
  return RxwebValidators.maxNumber({ conditionalExpression: () => maxCubeSize(trainingSessionTypeProvider()) === value, value });
}

function cubeSizeValidators(trainingSessionTypeProvider: () => TrainingSessionType | undefined) {
  const validators = [
    RxwebValidators.required(),
    RxwebValidators.digit(),
    // If this trainingSession only allows odd cube sizes, validate that.
    RxwebValidators.odd({ conditionalExpression: () => allowsOnlyOddCubeSizes(trainingSessionTypeProvider()) }),
    // If this trainingSession only allows odd cube sizes, validate that.
    RxwebValidators.even({ conditionalExpression: () => allowsOnlyEvenCubeSizes(trainingSessionTypeProvider()) }),
    // Always restrict the cube size to be between 2 and 7.
    RxwebValidators.minNumber({ value: 2 }),
    RxwebValidators.maxNumber({ value: 7 }),
    // For trainingSessions that have a minimum cube size of 7 or a maximum cube size of 2, add the conditional validators.
    minCubeSizeValidator(trainingSessionTypeProvider, 7),
    maxCubeSizeValidator(trainingSessionTypeProvider, 2),
  ];
  // For all possible cube sizes between 3 and 6, add conditional validators for minimum and maximum cube sizes.
  for (var i = 3; i <= 6; ++i) {
    validators.push(minCubeSizeValidator(trainingSessionTypeProvider, i));
    validators.push(maxCubeSizeValidator(trainingSessionTypeProvider, i));
  }
  return validators;
}


@Injectable({
  providedIn: 'root'
})
export class TrainingSessionFormsService {
  constructor(private readonly formBuilder: FormBuilder,
              private readonly uniqueTrainingSessionNameValidator: UniqueTrainingSessionNameValidator) {}

  trainingSessionTypeGroup(): FormGroup {
    return this.formBuilder.group({
      name: ['', { validators: Validators.required, asyncValidators: this.uniqueTrainingSessionNameValidator.validate, updateOn: 'blur' }],
      trainingSessionType: ['', Validators.required],
    });
  }

  algSetGroup(trainingSessionTypeProvider: () => TrainingSessionType | undefined): FormGroup {
    return this.formBuilder.group({
      algSet: [''],
    });
  }

  setupGroup(trainingSessionTypeProvider: () => TrainingSessionType | undefined): FormGroup {
    return this.formBuilder.group({
      cubeSize: ['', RxwebValidators.compose({
	conditionalExpression: () => hasMultipleCubeSizes(trainingSessionTypeProvider()),
	validators: cubeSizeValidators(trainingSessionTypeProvider),
      })],
      buffer: ['', RxwebValidators.required({ conditionalExpression: () => hasBuffer(trainingSessionTypeProvider()) })],
    });
  }

  trainingGroup(trainingSessionTypeProvider: () => TrainingSessionType | undefined): FormGroup {
    return this.formBuilder.group({
      showInputMode: ['', RxwebValidators.required({ conditionalExpression: () => hasMultipleShowInputModes(trainingSessionTypeProvider()) })],
      goalBadness: ['', RxwebValidators.compose({
	conditionalExpression: () => trainingSessionTypeProvider()?.hasGoalBadness,
	validators: [
	  RxwebValidators.required(),
	  RxwebValidators.numeric({ acceptValue: NumericValueType.PositiveNumber, allowDecimal: true })
	],
      })],
      memoTimeS: ['', RxwebValidators.compose({
	conditionalExpression: () => trainingSessionTypeProvider()?.hasMemoTime,
	validators: [
	  RxwebValidators.required(),
	  RxwebValidators.numeric({ acceptValue: NumericValueType.PositiveNumber, allowDecimal: true })
	],
      })],
      known: ['']
    });
  }
}
