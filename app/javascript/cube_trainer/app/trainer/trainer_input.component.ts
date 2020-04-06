import { Component, Input } from '@angular/core';
import { InputItem } from './input_item';

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
  input!: InputItem;
}
