import { Component, Input } from '@angular/core';
import { Mode } from '../modes/mode';
import { ShowInputMode } from '../modes/show-input-mode';
import { TrainerService } from './trainer.service';
import { InputItem } from './input-item';
import { ImgSide } from './img-side';

@Component({
  selector: 'cube-trainer-trainer-input',
  template: `
<ng-container *ngIf="showImage">
<div layout="row" layout-sm="column">
  <img id="trainerInputLeftImage" flex [src]="imgLeftSrc">
  <img id="trainerInputRightImage" flex [src]="imgRightSrc">
</div>
</ng-container>
<span class="trainer-input mat-elevation-z4" *ngIf="showName">{{input.representation}}</span>
<div class="hints" *ngIf="numHints > 0">
  <div class="hint" *ngFor="let hint of hints">
    {{hint}}
  </div>
</div>
`,
  styles: [`
.trainer-input {
  font-size: xxx-large;
}
`]
})
export class TrainerInputComponent {
  @Input()
  input!: InputItem;

  @Input()
  mode!: Mode

  @Input()
  numHints!: number;

  constructor(private readonly trainerService: TrainerService) {}

  get hints() {
    return this.input?.hints ? this.input.hints : [];
  }

  get showImage() {
    return this.mode && this.mode.showInputMode == ShowInputMode.Picture;
  }

  get showName() {
    return this.mode && this.mode.showInputMode == ShowInputMode.Name;
  }

  get imgLeftSrc() {
    return this.imgSrc(ImgSide.Left);
  }

  get imgRightSrc() {
    return this.imgSrc(ImgSide.Right);
  }

  imgSrc(imgSide: ImgSide) {
    return this.mode && this.input && this.showImage ? this.trainerService.inputImgSrc(this.mode, this.input, imgSide) : undefined;
  }
}
