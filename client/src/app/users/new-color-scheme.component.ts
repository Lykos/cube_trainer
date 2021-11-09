import { MatSnackBar } from '@angular/material/snack-bar';
import { UniqueColorSchemeNameValidator } from './unique-color-scheme-name.validator';
import { Router } from '@angular/router';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
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
    name: 'WCA',
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
	      private readonly router: Router,
              private readonly uniqueColorSchemeNameValidator: UniqueColorSchemeNameValidator) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get name() {
    return this.colorSchemeForm.get('name')!;
  }

  get faceEnum(): typeof Face {
    return Face;
  }

  get colorEnum(): typeof Color {
    return Color;
  }

  ngOnInit() {
    const formGroup: { [key: string]: any[]; } = {
      name: ['', { validators: Validators.required, asyncValidators: this.uniqueColorSchemeNameValidator.validate, updateOn: 'blur' }],
    };
    for (let [face, color] of Object.entries(this.wcaColorScheme)) {
      formGroup[face] = [color, Validators.required];
    }
    this.colorSchemeForm = this.formBuilder.group(formGroup);
  }

  get newColorScheme(): NewColorScheme {
    const colorScheme: any = {name: this.name.value!};
    for (let [face, _] of Object.entries(this.wcaColorScheme)) {
      colorScheme[face] = this.colorSchemeForm.get(face)!.value;
    }
    return colorScheme;
  }

  onSubmit() {
    this.colorSchemesService.create(this.newColorScheme).subscribe(r => {
      this.snackBar.open(`Color scheme ${this.newColorScheme.name} created!`, 'Close');
      this.router.navigate(['/color_schemes']);
    });
  }
}
