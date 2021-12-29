import { Component, Input } from '@angular/core';
import { TrainingSession } from '../training-session.model';
import { overrideAlgClick } from '@store/training-sessions.actions';
import { ShowInputMode } from '../show-input-mode.model';
import { Case } from '../case.model';
import { Store } from '@ngrx/store';

@Component({
  selector: 'cube-trainer-trainer-input',
  templateUrl: './trainer-input.component.html',
  styleUrls: ['./trainer-input.component.css']
})
export class TrainerInputComponent {
  @Input()
  casee?: Case;

  @Input()
  trainingSession?: TrainingSession;

  @Input()
  numHints?: number;

  constructor(private readonly store: Store) {}

  get setup() {
    return this.casee?.setup;
  }

  get puzzle() {
    const cubeSize = this.trainingSession?.cubeSize;
    return cubeSize ? `${cubeSize}x${cubeSize}x${cubeSize}` : undefined;
  }

  get alg() {
    return this.casee?.alg;
  }

  get showImage() {
    return this.trainingSession && this.trainingSession.showInputMode == ShowInputMode.Picture;
  }

  get showName() {
    return this.trainingSession && this.trainingSession.showInputMode == ShowInputMode.Name;
  }

  onOverride() {
    this.trainingSession && this.casee && this.store.dispatch(overrideAlgClick({ trainingSession: this.trainingSession, casee: this.casee }));
  }
}
