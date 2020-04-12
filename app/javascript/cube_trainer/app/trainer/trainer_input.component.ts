import { Component, Input, OnInit } from '@angular/core';
import { Mode } from '../mode/mode';
import { ShowInputMode } from '../mode/show-input-mode';
import { ModeService } from '../mode/mode.service';
import { TrainerService } from './trainer.service';
import { InputItem } from './input_item';
import { ImgSide } from './img-side';
import { Observable } from 'rxjs';

@Component({
  selector: 'trainer-input',
  template: `
<ng-container *ngIf="showImage">
<div layout="row" layout-sm="column">
  <img flex [src]="imgLeftSrc">
  <img flex [src]="imgRightSrc">
</div>
</ng-container>
<span class="trainer-input" *ngIf="showName">{{input.inputRepresentation}}</span>
`
})
export class TrainerInputComponent implements OnInit {
  @Input()
  input: InputItem | undefined = undefined;

  @Input()
  modeId$!: Observable<number>;

  mode: Mode | undefined = undefined;

  constructor(private readonly trainerService: TrainerService,
	      private readonly modeService: ModeService) {}

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

  ngOnInit() {
    this.modeId$.subscribe(modeId => {
      this.modeService.show(modeId).subscribe(mode => this.mode = mode);
    });
  }
}
