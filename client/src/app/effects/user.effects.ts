import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { Injectable } from '@angular/core';
import { METADATA } from '@shared/metadata.const';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { catchError, exhaustMap, map, tap } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, login, loginSuccess, loginFailure, logout, logoutSuccess, logoutFailure } from '@store/user.actions';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { UsersService } from '@core/users.service';
import { Router } from '@angular/router';
 
@Injectable()
export class UserEffects {
  constructor(
    private actions$: Actions,
    private readonly dialog: MatDialog,
    private readonly usersService: UsersService,
    private readonly router: Router,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(action =>
        this.usersService.show().pipe(
          map(user => initialLoadSuccess({ user })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'user',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(initialLoadFailure({ error }));
          })
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
          catchError(httpResponseError => {
            const context = {
              action: 'logging in',
              subject: 'user',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(loginFailure({ error }));
          })
        )
      )
    )
  );

  loginSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loginSuccess),
      tap(() => {
        const storedRedirectUrl = localStorage.getItem(METADATA.signInStoredUrlStorageKey);
        if (storedRedirectUrl) {
          localStorage.removeItem(METADATA.signInStoredUrlStorageKey);
        }
        const redirectUrl = storedRedirectUrl || '/training-sessions';
        this.router.navigate([redirectUrl]);
      })
    ),
    { dispatch: false },
  );

  logout$ = createEffect(() =>
    this.actions$.pipe(
      ofType(logout),
      exhaustMap(action =>
        this.usersService.logout().pipe(
          map(user => logoutSuccess()),
          catchError(httpResponseError => {
            const context = {
              action: 'logging out',
              subject: 'user',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(logoutFailure({ error }));
          })
        )
      )
    )
  );

  logoutFailure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(logoutFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );

  logoutSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(logoutSuccess),
      tap(() => { this.router.navigate(['/logged-out']); })
    ),
    { dispatch: false },
  );
}
