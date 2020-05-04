import { Component } from '@angular/core';

enum Face {
  U = 'U',
  F = 'F',
  R = 'R',
  L = 'L',
  B = 'B',
  D = 'D',
}

enum Color {
  Black = 'black',
  DarkGrey = 'dark grey',
  Grey = 'grey',
  Silver = 'silver',
  White = 'white',
  Yellow = 'yellow',
  Red = 'red',
  Orange = 'orange',
  Blue = 'blue',
  Green = 'green',
  Purple = 'purple',
  Pink = 'pink'
}

interface FaceConfig {
  readonly face: Face;
  readonly defaultColor: Color;
}

@Component({
  selector: 'signup',
  template: `
<div>
  <h1>Pick Color Scheme</h1>
  <form>
    <ng-container *ngFor="let faceConfig of faceConfigs">
      <mat-form-field>
        <mat-label>{{faceConfig.name}}</mat-label>
        <mat-select value="faceConfig.defaultColor">
          <mat-option *ngFor="let color of colors" [value]="color"> {{color}} </mat-option>
        </mat-select>
        <mat-error *ngIf="relevantInvalid(modeType) && modeType.errors.required">
          You must provide a <strong>mode type</strong>.
        </mat-error>
      </mat-form-field>
    </ng-container>
    <div>
      <button mat-raised-button color="primary" type="Submit">Submit</button>
    </div>
  </form>
</div>
`
})
export class ColorSchemeComponent {
  readonly faceConfigs: FaceConfig[] = [
    { face: Face.U, defaultColor: Color.White },
    { face: Face.F, defaultColor: Color.Green },
    { face: Face.R, defaultColor: Color.Red },
    { face: Face.L, defaultColor: Color.Orange },
    { face: Face.B, defaultColor: Color.Blue },
    { face: Face.D, defaultColor: Color.Yellow },
  ]
}
