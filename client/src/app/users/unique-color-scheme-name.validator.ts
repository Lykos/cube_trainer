import { Injectable } from '@angular/core'
import { AsyncValidator, AsyncValidatorFn, AbstractControl } from '@angular/forms';
import { ColorSchemesService } from './color-schemes.service';
import { of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UniqueColorSchemeNameValidator implements AsyncValidator {
  constructor(private colorSchemesService: ColorSchemesService) {}

  validate: AsyncValidatorFn = (ctrl: AbstractControl) => {
    return this.colorSchemesService.isColorSchemeNameTaken(ctrl.value).pipe(
      map(isTaken => (isTaken ? { uniqueColorSchemeName: true } : null)),
      catchError(() => of(null))
    );
  }
}
