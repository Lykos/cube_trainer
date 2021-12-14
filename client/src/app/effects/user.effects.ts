import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { catchError, exhaustMap, map } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, login, loginSuccess, loginFailure, logout, logoutSuccess, logoutFailure } from '../state/user.actions';
import { UsersService } from '../users/users.service';
 
@Injectable()
export class UserEffects {
  constructor(
    private actions$: Actions,
    private readonly usersService: UsersService
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(
        action =>
          this.usersService.show().pipe(
            map(user => initialLoadSuccess({ user })),
            catchError(error => of(initialLoadFailure({ error })))
          )
      )
    )
  );

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

  logout$ = createEffect(() =>
    this.actions$.pipe(
      ofType(logout),
      exhaustMap(
        action =>
          this.usersService.logout().pipe(
            map(user => logoutSuccess()),
            catchError(error => of(logoutFailure({ error })))
          )
      )
    )
  );
}
