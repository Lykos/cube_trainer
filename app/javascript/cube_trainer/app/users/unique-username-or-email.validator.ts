import { Injectable } from '@angular/core'
import { AsyncValidator, AsyncValidatorFn, AbstractControl } from '@angular/forms';
import { UsersService } from './users.service';
import { of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UniqueUsernameOrEmailValidator implements AsyncValidator {
  constructor(private usersService: UsersService) {}

  validate: AsyncValidatorFn = (ctrl: AbstractControl) => {
    return this.usersService.isUsernameOrEmailTaken(ctrl.value).pipe(
      map(isTaken => (isTaken ? { uniqueUsernameOrEmail: true } : null)),
      catchError(() => of(null))
    );
  }
}
