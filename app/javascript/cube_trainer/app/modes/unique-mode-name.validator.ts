import { Injectable } from '@angular/core'
import { AsyncValidator, AsyncValidatorFn, AbstractControl } from '@angular/forms';
import { ModesService } from './modes.service';
import { of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UniqueModeNameValidator implements AsyncValidator {
  constructor(private modesService: ModesService) {}

  validate: AsyncValidatorFn = (ctrl: AbstractControl) => {
    return this.modesService.isModeNameTaken(ctrl.value).pipe(
      map(isTaken => (isTaken ? { uniqueModeName: true } : null)),
      catchError(() => of(null))
    );
  }
}
