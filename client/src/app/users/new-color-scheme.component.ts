import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { NewColorScheme } from './new-color-scheme.model';
import { ColorSchemesService } from './color-schemes.service';
import { Color } from './color.model';
import { Face } from './face.model';

@Component({
  selector: 'cube-trainer-color-scheme',
  templateUrl: './new-color-scheme.component.html'
})
export class NewColorSchemeComponent implements OnInit {
  colorSchemeForm!: FormGroup;

  readonly wcaColorScheme: NewColorScheme = {
    U: Color.White,
    F: Color.Green,
    R: Color.Red,
    L: Color.Orange,
    B: Color.Blue,
    D: Color.Yellow,
  }

  constructor(private readonly formBuilder: FormBuilder,
              private readonly colorSchemesService: ColorSchemesService,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router) {}

  get faceEnum(): typeof Face {
    return Face;
  }

  get colorEnum(): typeof Color {
    return Color;
  }

  ngOnInit() {
    const formGroup: { [key: string]: any[]; } = {};
    for (let [face, color] of Object.entries(this.wcaColorScheme)) {
      formGroup[face] = [color, Validators.required];
    }
    this.colorSchemeForm = this.formBuilder.group(formGroup);
  }

  get colorScheme(): NewColorScheme {
    const colorScheme: any = {};
    for (let [face, _] of Object.entries(this.wcaColorScheme)) {
      colorScheme[face] = this.colorSchemeForm.get(face)!.value;
    }
    console.log(colorScheme);
    return colorScheme;
  }

  onSubmit() {
    this.colorSchemesService.create(this.colorScheme).subscribe(r => {
      this.snackBar.open('Signup successful!', 'Close');
      this.router.navigate(['/color_schemes']);
    });
  }
}
