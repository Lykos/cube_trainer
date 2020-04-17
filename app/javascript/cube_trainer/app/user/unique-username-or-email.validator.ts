import { Injectable } from '@angular/core'
import { AsyncValidator, AsyncValidatorFn, AbstractControl } from '@angular/forms';
import { UserService } from './user.service';
import { of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UniqueUsernameOrEmailValidator implements AsyncValidator {
  constructor(private userService: UserService) {}

  validate: AsyncValidatorFn = (ctrl: AbstractControl) => {
    return this.userService.isUsernameOrEmailTaken(ctrl.value).pipe(
      map(isTaken => (isTaken ? { uniqueUsernameOrEmail: true } : null)),
      catchError(() => of(null))
    );
  }
}
