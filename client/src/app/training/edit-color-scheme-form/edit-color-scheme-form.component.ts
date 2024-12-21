import { Component, Input, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { ColorScheme } from '../color-scheme.model';
import { Optional, none, orElse, mapOptional, ifPresent } from '@utils/optional';
import { NewColorScheme } from '../new-color-scheme.model';
import { Color } from '../color.model';
import { Store } from '@ngrx/store';
import { create, update } from '@store/color-scheme.actions';

@Component({
  selector: 'cube-trainer-edit-color-scheme-form',
  templateUrl: './edit-color-scheme-form.component.html'
})
export class EditColorSchemeFormComponent implements OnInit {
  colorSchemeForm: FormGroup;

  @Input()
  existingColorScheme: Optional<ColorScheme> = none;

  constructor(private readonly formBuilder: FormBuilder,
	      private readonly store: Store) {
    this.colorSchemeForm = this.formBuilder.group({
      colorU: [Color.White, Validators.required],
      colorF: [Color.Green, Validators.required],
    });
  }

  ngOnInit() {
    ifPresent(
      this.existingColorScheme,
      colorScheme => {
	this.colorSchemeForm.get('colorU')!.setValue(colorScheme.colorU);
	this.colorSchemeForm.get('colorF')!.setValue(colorScheme.colorF);
      }
    );
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get colorEnum(): typeof Color {
    return Color;
  }

  get newColorScheme(): NewColorScheme {
    return {
      colorU: this.colorSchemeForm!.get('colorU')!.value,
      colorF: this.colorSchemeForm!.get('colorF')!.value,
    }
  }

  onSubmit() {
    const createOrUpdate: any = orElse(
      mapOptional(
	this.existingColorScheme,
	colorScheme => update({ newColorScheme: this.newColorScheme }),
      ) as any,
      create({ newColorScheme: this.newColorScheme }) as any,
    );
    this.store.dispatch(createOrUpdate);
  }
}
