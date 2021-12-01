import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { NewColorScheme } from '../new-color-scheme.model';
import { ColorSchemesService } from '../color-schemes.service';
import { Color } from '../color.model';
import { Face } from '../face.model';
import { of } from 'rxjs';
import { catchError } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-color-scheme',
  templateUrl: './new-color-scheme.component.html'
})
export class NewColorSchemeComponent implements OnInit {
  colorSchemeForm!: FormGroup;

  readonly wcaColorScheme: NewColorScheme = {
    U: Color.White,
    F: Color.Green,
  }

  constructor(private readonly formBuilder: FormBuilder,
              private readonly colorSchemesService: ColorSchemesService,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

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

  get newColorScheme(): NewColorScheme {
    const colorScheme: any = {};
    for (let [face, _] of Object.entries(this.wcaColorScheme)) {
      colorScheme[face] = this.colorSchemeForm.get(face)!.value;
    }
    return colorScheme;
  }

  onSubmit() {
    let message = 'Color scheme overwritten!'
    this.colorSchemesService.destroy()
      .pipe(catchError((e: any) => {
        message = 'Color scheme created!';
        return of(undefined);
      }))
      .subscribe(r => {
        this.colorSchemesService.create(this.newColorScheme).subscribe(r => {
          this.snackBar.open(message, 'Close');
          this.router.navigate(['/user']);
        });
      });
  }
}
