import { Component, Input } from '@angular/core';

export interface InputItem {
  readonly id: number;
  readonly inputRepresentation: String;
};

@Component({
  selector: 'trainer-input',
  template: `
<mat-card *ngIf="input">
  <mat-card-title>Input</mat-card-title>
  <mat-card-content>{{input.inputRepresentation}}</mat-card-content>
</mat-card>
`
})
export class TrainerInputComponent {
  @Input()
  input: InputItem | undefined = undefined;
}
