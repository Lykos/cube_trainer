import { Component } from '@angular/core';
import { FormGroup, AbstractControl } from '@angular/forms';
import { TrainingSessionType } from '../training-session-type.model';
import { TrainingSessionsService } from '../training-sessions.service';
import { TrainingSessionFormsService } from '../training-session-forms.service';
import { NewTrainingSession } from '../new-training-session.model';
import { AlgSet } from '../alg-set.model';
import { StatType } from '../stat-type.model';
import { Observable } from 'rxjs';
import { CdkDragDrop, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';
import { create } from '@store/training-sessions.actions';
import { Store } from '@ngrx/store';

@Component({
  selector: 'cube-trainer-new-training-session',
  templateUrl: './new-training-session.component.html',
  styleUrls: ['./new-training-session.component.css']
})
export class NewTrainingSessionComponent {
  trainingSessionTypeGroup: FormGroup;
  algSetGroup: FormGroup;
  setupGroup: FormGroup;
  trainingGroup: FormGroup;
  trainingSessionTypes$: Observable<TrainingSessionType[]>;
  pickedStatTypes: StatType[] = [];

  lastTrainingSessionTypeForStatsTypes: TrainingSessionType | undefined
  statTypesForLastTrainingSessionType: StatType[] = [];
  
  constructor(private readonly trainingSessionFormsService: TrainingSessionFormsService,
	      private readonly trainingSessionsService: TrainingSessionsService,
              private readonly store: Store) {
    this.trainingSessionTypes$ = this.trainingSessionsService.listTypes();
    this.trainingSessionTypeGroup = this.trainingSessionFormsService.trainingSessionTypeGroup();
    this.algSetGroup = this.trainingSessionFormsService.algSetGroup(() => this.trainingSessionType);
    this.setupGroup = this.trainingSessionFormsService.setupGroup(() => this.trainingSessionType);
    this.trainingGroup = this.trainingSessionFormsService.trainingGroup(() => this.trainingSessionType);
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get name() {
    return this.trainingSessionTypeGroup.get('name')!;
  }

  get statTypesForCurrentTrainingSessionType() {
    if (this.lastTrainingSessionTypeForStatsTypes !== this.trainingSessionType) {
      this.statTypesForLastTrainingSessionType = Object.assign([], this.trainingSessionType!.statsTypes);
      this.lastTrainingSessionTypeForStatsTypes = this.trainingSessionType;
    }
    return this.statTypesForLastTrainingSessionType;
  }

  get hasMultipleShowInputModes() {
    return this.trainingSessionType && this.trainingSessionType.showInputModes.length > 1;
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

  get defaultCubeSize() {
    return this.trainingSessionType?.cubeSizeSpec?.default;
  }

  get minCubeSize() {
    return this.trainingSessionType?.cubeSizeSpec?.min;
  }

  get maxCubeSize() {
    return this.trainingSessionType?.cubeSizeSpec?.max;
  }

  get trainingSessionTypeControl(): AbstractControl {
    return this.trainingSessionTypeGroup.get('trainingSessionType')!;
  }

  get trainingSessionType(): TrainingSessionType | undefined {
    return this.trainingSessionTypeControl.value;
  }

  get algSetControl(): AbstractControl {
    return this.algSetGroup.get('algSet')!;
  }

  get algSet(): AlgSet | undefined {
    return this.algSetControl.value;
  }

  get selectedShowInputMode() {
    if (this.trainingSessionType && this.trainingSessionType.showInputModes.length == 1) {
      return this.trainingSessionType.showInputModes[0];
    } else if (this.hasMultipleShowInputModes) {
      return this.showInputMode.value;
    } else {
      return undefined;
    }
  }

  get hasMultipleCubeSizes(): boolean {
    const cubeSizeSpec = this.trainingSessionType?.cubeSizeSpec;
    return !!cubeSizeSpec && cubeSizeSpec.min < cubeSizeSpec.max;
  }

  get selectedCubeSize(): number | undefined {
    if (this.hasMultipleCubeSizes) {
      return this.cubeSize.value;
    } else {
      return this.defaultCubeSize;
    }
  }

  get bufferAlgSets(): AlgSet[] {
    const trainingSessionType = this.trainingSessionType;
    if (!trainingSessionType || !trainingSessionType?.buffers?.length) {
      return [];
    }
    const buffer = this.buffer.value;
    if (!buffer) {
      return [];
    }
    console.log(trainingSessionType.algSets);
    return trainingSessionType.algSets.filter(a => a.buffer.key === buffer.key);
  }

  get newTrainingSession(): NewTrainingSession {
    return {
      trainingSessionType: this.trainingSessionType!,
      name: this.name.value,
      known: !!this.trainingGroup.get('known')?.value,
      showInputMode: this.selectedShowInputMode,
      buffer: this.buffer.value,
      goalBadness: this.goalBadness.value,
      memoTimeS: this.memoTimeS.value,
      cubeSize: this.selectedCubeSize,
      statTypes: this.pickedStatTypes.map(s => s.key),
      algSet: this.algSet,
    };
  }

  onSubmit() {
    this.store.dispatch(create({ newTrainingSession: this.newTrainingSession }));
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

  get trainingSessionTypesContext() {
    return {
      action: 'loading',
      subject: 'session types',
    };
  }
}
