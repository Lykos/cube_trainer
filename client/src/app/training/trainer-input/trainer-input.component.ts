import { Component, Input } from '@angular/core';
import { Mode } from '../mode.model';
import { overrideAlgClick } from '@store/modes.actions';
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
  mode?: Mode;

  @Input()
  numHints?: number;

  constructor(private readonly store: Store) {}

  get setup() {
    return this.casee?.setup;
  }

  get puzzle() {
    const cubeSize = this.mode?.cubeSize;
    return cubeSize ? `${cubeSize}x${cubeSize}x${cubeSize}` : undefined;
  }

  get alg() {
    return this.casee?.alg;
  }

  get showImage() {
    return this.mode && this.mode.showInputMode == ShowInputMode.Picture;
  }

  get showName() {
    return this.mode && this.mode.showInputMode == ShowInputMode.Name;
  }

  onOverride() {
    this.mode && this.casee && this.store.dispatch(overrideAlgClick({ mode: this.mode, casee: this.casee }));
  }
}
