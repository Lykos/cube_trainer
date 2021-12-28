import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { NewColorScheme } from '../new-color-scheme.model';
import { ColorSchemesService } from '../color-schemes.service';
import { Color } from '../color.model';
import { of } from 'rxjs';
import { catchError } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-color-scheme',
  templateUrl: './new-color-scheme.component.html'
})
export class NewColorSchemeComponent implements OnInit {
  colorSchemeForm!: FormGroup;

  readonly wcaColorScheme: NewColorScheme = {
    colorU: Color.White,
    colorF: Color.Green,
  }

  constructor(private readonly formBuilder: FormBuilder,
              private readonly colorSchemesService: ColorSchemesService,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get colorEnum(): typeof Color {
    return Color;
  }

  ngOnInit() {
    this.colorSchemeForm = this.formBuilder.group({
      colorU: [Color.White, Validators.required],
      colorF: [Color.Green, Validators.required],
    });
  }

  get newColorScheme(): NewColorScheme {
    return {
      colorU: this.colorSchemeForm.get('colorU')!.value,
      colorF: this.colorSchemeForm.get('colorF')!.value,
    }
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
