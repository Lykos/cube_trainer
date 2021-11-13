import { MatSnackBar } from '@angular/material/snack-bar';
import { UniqueLetterSchemeNameValidator } from './unique-letter-scheme-name.validator';
import { Router } from '@angular/router';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { NewLetterScheme } from './new-letter-scheme.model';
import { LetterSchemesService } from './letter-schemes.service';
import { PartTypesService } from './part-types.service';
import { PartType } from './part-type.model';

@Component({
  selector: 'cube-trainer-letter-scheme',
  templateUrl: './new-letter-scheme.component.html'
})
export class NewLetterSchemeComponent implements OnInit {
  letterSchemeForm?: FormGroup;
  partTypes!: PartType[];

  constructor(private readonly formBuilder: FormBuilder,
              private readonly partTypesService: PartTypesService,
              private readonly letterSchemesService: LetterSchemesService,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router,
              private readonly uniqueLetterSchemeNameValidator: UniqueLetterSchemeNameValidator) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get nameModel() {
    return this.letterSchemeForm?.get('name');
  }

  ngOnInit() {
    this.partTypesService.list().subscribe((partTypes: PartType[]) => {
      this.partTypes = partTypes
      const formGroup: { [key: string]: any; } = {
        name: ['', { validators: Validators.required, asyncValidators: this.uniqueLetterSchemeNameValidator.validate, updateOn: 'blur' }],
      };
      partTypes.forEach(partType => {
        const partGroup: { [key: string]: any[]; } = {};
        partType.parts.forEach(part => {
          partGroup[part] = [''];
        });
        formGroup[partType.name] = this.formBuilder.group(partGroup);
      });
      this.letterSchemeForm = this.formBuilder.group(formGroup);
    });
  }

  get newLetterScheme(): NewLetterScheme {
    return {
      name: this.nameModel!.value!,
      mappings: this.partTypes.flatMap(partType => {
        return partType.parts.map(part => {
          return {
            partType: partType.name,
            part: part,
            letter: this.letterSchemeForm!.get(partType.name)!.get(part)!.value,
          };
        });
      }),
    };
  }

  onSubmit() {
    this.letterSchemesService.create(this.newLetterScheme).subscribe(r => {
      this.snackBar.open(`Letter scheme ${this.newLetterScheme.name} created!`, 'Close');
      this.router.navigate(['/letter_schemes']);
    });
  }
}
