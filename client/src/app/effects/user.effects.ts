import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { catchError, exhaustMap, map } from 'rxjs/operators';
import { login, loginSuccess, loginFailure } from '../state/user.actions';
import { UsersService } from '../users/users.service';
 
@Injectable()
export class UserEffects {
  constructor(
    private actions$: Actions,
    private readonly usersService: UsersService
  ) {}

  login$ = createEffect(() =>
    this.actions$.pipe(
      ofType(login),
      exhaustMap(
        action =>
          this.usersService.login(action.credentials).pipe(
            map(user => loginSuccess({ user })),
            catchError(error => of(loginFailure({ error })))
          )
      )
    )
  );
}
