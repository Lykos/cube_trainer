import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, AbstractControl } from '@angular/forms';
import { NewLetterScheme } from '../new-letter-scheme.model';
import { LetterSchemeMapping } from '../letter-scheme-base.model';
import { LetterSchemesService } from '../letter-schemes.service';
import { AuthenticationService } from '../authentication.service';
import { PartTypesService } from '../part-types.service';
import { PartType } from '../part-type.model';
import { of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { forceValue } from '../../utils/optional';

@Component({
  selector: 'cube-trainer-letter-scheme',
  templateUrl: './new-letter-scheme.component.html'
})
export class NewLetterSchemeComponent implements OnInit {
  letterSchemeForm?: FormGroup;
  partTypes!: PartType[];

  constructor(private readonly authenticationService: AuthenticationService,
	      private readonly formBuilder: FormBuilder,
              private readonly partTypesService: PartTypesService,
              private readonly letterSchemesService: LetterSchemesService,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get separator() {
    return ':';
  }

  partKey(partType: PartType, part: string) {
    return `#{partType}#{this.separator}#{part}`;
  }

  ngOnInit() {
    this.letterSchemesService.destroy();
    this.partTypesService.list().subscribe((partTypes: PartType[]) => {
      this.partTypes = partTypes
      const formGroup: { [key: string]: any; } = {};
      partTypes.forEach(partType => {
        partType.parts.forEach(part => {
          formGroup[part.key] = [''];
        });
      });
      this.letterSchemeForm = this.formBuilder.group(formGroup);
    });
  }

  get newLetterScheme(): NewLetterScheme {
    const mappings: LetterSchemeMapping[] = [];
    this.partTypes.forEach(partType => {
      return partType.parts.forEach(part => {
        const letter = this.letterSchemeForm!.get(part.key)!.value;
        if (letter) {
          mappings.push({part, letter});
        }
      });
    });
    return { mappings };
  }

  onSubmit() {
    let message = 'Letter scheme overwritten!'
    this.letterSchemesService.destroy()
      .pipe(catchError((e: any) => {
        message = 'Letter scheme created!';
        return of(undefined);
      }))
      .subscribe(r => {
        this.letterSchemesService.create(this.newLetterScheme).subscribe(r => {
          this.snackBar.open(message, 'Close');
          this.authenticationService.currentUser$.subscribe(user => {
            this.router.navigate([`/users/${forceValue(user).id}`]);
          });
        });
      });
  }
}
