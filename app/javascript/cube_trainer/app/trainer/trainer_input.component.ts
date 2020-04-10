import { Component, Input, OnInit } from '@angular/core';
import { Mode } from '../mode/mode';
import { ShowInputMode } from '../mode/show-input-mode';
import { ModeService } from '../mode/mode.service';
import { TrainerService } from './trainer.service';
import { InputItem } from './input_item';
import { Observable } from 'rxjs';

@Component({
  selector: 'trainer-input',
  template: `
<mat-card>
  <mat-card-title>Input</mat-card-title>
  <img mat-card-img *ngIf="showImage" [src]="imgSrc">
  <mat-card-content *ngIf="showName">{{input.inputRepresentation}}</mat-card-content>
</mat-card>
`
})
export class TrainerInputComponent implements OnInit {
  @Input()
  input!: InputItem;

  @Input()
  modeId$!: Observable<number>;

  mode!: Mode;

  constructor(private readonly trainerService: TrainerService,
	      private readonly modeService: ModeService) {}

  get showImage() {
    return this.mode.showInputMode == ShowInputMode.Picture;
  }

  get showName() {
    return this.mode.showInputMode == ShowInputMode.Name;
  }

  get imgSrc() {
    return this.trainerService.inputImgSrc(this.mode, this.input);
  }

  ngOnInit() {
    this.modeId$.subscribe(modeId => {
      this.modeService.show(modeId).subscribe(mode => {console.log(mode); this.mode = mode});
    });
  }
}
