import { Injectable } from '@angular/core'
import { AsyncValidator, AsyncValidatorFn, AbstractControl } from '@angular/forms';
import { LetterSchemesService } from './letter-schemes.service';
import { of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UniqueLetterSchemeNameValidator implements AsyncValidator {
  constructor(private letterSchemesService: LetterSchemesService) {}

  validate: AsyncValidatorFn = (ctrl: AbstractControl) => {
    return this.letterSchemesService.isLetterSchemeNameTaken(ctrl.value).pipe(
      map(isTaken => (isTaken ? { uniqueLetterSchemeName: true } : null)),
      catchError(() => of(null))
    );
  }
}
