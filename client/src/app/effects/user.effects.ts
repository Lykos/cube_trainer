import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { catchError, exhaustMap, map, tap } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, login, loginSuccess, loginFailure, logout, logoutSuccess, logoutFailure } from '../state/user.actions';
import { UsersService } from '../users/users.service';
import { Router } from '@angular/router';
 
@Injectable()
export class UserEffects {
  constructor(
    private actions$: Actions,
    private readonly usersService: UsersService,
    private readonly router: Router,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(action =>
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
      exhaustMap(action =>
        this.usersService.login(action.credentials).pipe(
          map(user => loginSuccess({ user })),
          catchError(error => of(loginFailure({ error })))
        )
      )
    )
  );

  loginSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loginSuccess),
      tap(() => { this.router.navigate(['/modes']); })
    ),
    { dispatch: false },
  );

  logout$ = createEffect(() =>
    this.actions$.pipe(
      ofType(logout),
      exhaustMap(action =>
        this.usersService.logout().pipe(
          map(user => logoutSuccess()),
          catchError(error => of(logoutFailure({ error })))
        )
      )
    )
  );

  logoutSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(logoutSuccess),
      tap(() => { this.router.navigate(['/logged_out']); })
    ),
    { dispatch: false },
  );
}
