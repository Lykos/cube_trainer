import { Component, Input, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { TrainingSession } from '../training-session.model';
import { ShowInputMode } from '../show-input-mode.model';
import { ScrambleOrSample, isScramble, isSample } from '../scramble-or-sample.model';
import { ColorScheme } from '../color-scheme.model';
import { MatTooltipModule } from '@angular/material/tooltip';

@Component({
  selector: 'cube-trainer-trainer-input',
  templateUrl: './trainer-input.component.html',
  styleUrls: ['./trainer-input.component.css'],
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
  imports: [MatTooltipModule],
})
export class TrainerInputComponent {
  @Input()
  scrambleOrSample?: ScrambleOrSample | null;

  @Input()
  trainingSession?: TrainingSession;

  @Input()
  colorScheme?: ColorScheme | null;

  get scramble() {
    const scrambleOrSample = this.scrambleOrSample;
    return scrambleOrSample && isScramble(scrambleOrSample) ? scrambleOrSample.scramble : undefined;
  }

  get sample() {
    const scrambleOrSample = this.scrambleOrSample;
    return scrambleOrSample && isSample(scrambleOrSample) ? scrambleOrSample.sample : undefined;
  }

  get pictureSetup() {
    return this.sample?.item?.pictureSetup || this.colorScheme?.setup || '';
  }

  get puzzle() {
    const cubeSize = this.trainingSession?.cubeSize;
    return cubeSize ? `${cubeSize}x${cubeSize}x${cubeSize}` : undefined;
  }

  get caseName() {
    return this.sample?.item?.casee?.name || ' ';
  }

  get showImage() {
    return this.trainingSession && this.trainingSession.showInputMode == ShowInputMode.Picture;
  }

  get showName() {
    return this.trainingSession && this.trainingSession.showInputMode == ShowInputMode.Name;
  }

  get showScramble() {
    return this.trainingSession && this.trainingSession.showInputMode == ShowInputMode.Scramble;
  }

  get sampleTooltip() {
    if (!this.sample) {
      return '';
    }
    return `Item was chosen by sampling strategy ${this.sample.samplerName}`;
  }
}
