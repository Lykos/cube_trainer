import { Component, Input, OnInit } from '@angular/core';
import { Mode } from '../modes/mode';
import { ShowInputMode } from '../modes/show-input-mode';
import { ModesService } from '../modes/modes.service';
import { TrainerService } from './trainer.service';
import { InputItem } from './input-item';
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
<span class="trainer-input mat-elevation-z2" *ngIf="showName">{{input.representation}}</span>
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
export class TrainerInputComponent implements OnInit {
  @Input()
  input: InputItem | undefined = undefined;

  @Input()
  modeId$!: Observable<number>;

  @Input()
  numHints$!: Observable<number>;

  mode: Mode | undefined = undefined;
  numHints: number | undefined = undefined;

  constructor(private readonly trainerService: TrainerService,
	      private readonly modesService: ModesService) {}

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

  ngOnInit() {
    this.modeId$.subscribe(modeId => {
      this.modesService.show(modeId).subscribe(mode => this.mode = mode);
    });
    this.numHints$.subscribe(numHints => this.numHints = numHints);
  }
}
