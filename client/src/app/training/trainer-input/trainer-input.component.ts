import { Component, Input } from '@angular/core';
import { Sample } from '@utils/sampling';
import { TrainingSession } from '../training-session.model';
import { ShowInputMode } from '../show-input-mode.model';
import { TrainingCase } from '../training-case.model';

@Component({
  selector: 'cube-trainer-trainer-input',
  templateUrl: './trainer-input.component.html',
  styleUrls: ['./trainer-input.component.css']
})
export class TrainerInputComponent {
  @Input()
  sample?: Sample<TrainingCase>;

  @Input()
  trainingSession?: TrainingSession;

  get setup() {
    return this.sample?.item?.setup;
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

  get tooltip() {
    if (!this.sample) {
      return '';
    }
    return `Item was chosen by sampling strategy ${this.sample.samplerName}`;
  }
}
