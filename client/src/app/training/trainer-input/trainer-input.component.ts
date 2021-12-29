import { Component, Input } from '@angular/core';
import { TrainingSession } from '../training-session.model';
import { ShowInputMode } from '../show-input-mode.model';
import { Case } from '../case.model';

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

  get setup() {
    return this.casee?.setup;
  }

  get puzzle() {
    const cubeSize = this.trainingSession?.cubeSize;
    return cubeSize ? `${cubeSize}x${cubeSize}x${cubeSize}` : undefined;
  }

  get showImage() {
    return this.trainingSession && this.trainingSession.showInputMode == ShowInputMode.Picture;
  }

  get showName() {
    return this.trainingSession && this.trainingSession.showInputMode == ShowInputMode.Name;
  }
}
