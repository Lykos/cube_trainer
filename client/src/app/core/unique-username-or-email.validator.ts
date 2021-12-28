import { Injectable } from '@angular/core'
import { AsyncValidatorFn, AbstractControl } from '@angular/forms';
import { UsersService } from './users.service';
import { of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UniqueUsernameOrEmailValidator {
  constructor(private usersService: UsersService) {}

  validate(previousValidValue?: string): AsyncValidatorFn {
    return (ctrl: AbstractControl) => {
      if (previousValidValue && ctrl.value === previousValidValue) {
	return of(null);
      }
      return this.usersService.isNameOrEmailTaken(ctrl.value).pipe(
	map(isTaken => (isTaken ? { uniqueUsernameOrEmail: true } : null)),
	catchError(() => of(null))
      );
    };
  }
}
