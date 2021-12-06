import { Component, Input } from '@angular/core';
import { Mode } from '../../modes/mode.model';
import { ShowInputMode } from '../../modes/show-input-mode.model';
import { InputItem } from '../input-item.model';

@Component({
  selector: 'cube-trainer-trainer-input',
  templateUrl: './trainer-input.component.html',
  styleUrls: ['./trainer-input.component.css']
})
export class TrainerInputComponent {
  @Input()
  input?: InputItem;

  @Input()
  mode?: Mode;

  @Input()
  numHints?: number;

  constructor() {}

  get setup() {
    return this.input?.setup;
  }

  get puzzle() {
    const cubeSize = this.mode?.cubeSize;
    console.log(`${cubeSize}x${cubeSize}x${cubeSize}`);
    return cubeSize ? `${cubeSize}x${cubeSize}x${cubeSize}` : undefined;
  }

  get hints() {
    return this.input?.hints ? this.input.hints : [];
  }

  get showImage() {
    return this.mode && this.mode.showInputMode == ShowInputMode.Picture;
  }

  get showName() {
    return this.mode && this.mode.showInputMode == ShowInputMode.Name;
  }
}
