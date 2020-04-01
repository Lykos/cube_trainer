import { Component, Input } from '@angular/core';

interface InputItem {
  readonly id: number;
  readonly inputRepresentation: String;
};

@Component({
  selector: 'timer-input',
  template: `
<mat-card *ngIf="input">
  <mat-card-title>Input</mat-card-title>
  <mat-card-content>{{input.inputRepresentation}}</mat-card-content>
</mat-card>
`
})
export class TimerInputComponent implements OnChanges {
  @Input()
  input: InputItem = undefined;
}
