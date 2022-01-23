import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { MatSnackBar } from '@angular/material/snack-bar';
import { of } from 'rxjs';
import { catchError, exhaustMap, map, tap } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, update, updateSuccess, updateFailure } from '@store/letter-scheme.actions';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { LetterSchemesService } from '@training/letter-schemes.service';
import { Router } from '@angular/router';
 
@Injectable()
export class LetterSchemeEffects {
  constructor(
    private actions$: Actions,
    private readonly dialog: MatDialog,
    private readonly letterSchemesService: LetterSchemesService,
    private readonly snackBar: MatSnackBar,
    private readonly router: Router,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(action =>
        this.letterSchemesService.show().pipe(
          map(letterScheme => initialLoadSuccess({ letterScheme })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'letter scheme',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(initialLoadFailure({ error }));
          })
        )
      )
    )
  );

  create$ = createEffect(() =>
    this.actions$.pipe(
      ofType(create),
      exhaustMap(action =>
        this.letterSchemesService.create(action.newLetterScheme).pipe(
          map(letterScheme => createSuccess({ newLetterScheme: action.newLetterScheme, letterScheme })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating',
              subject: 'letter scheme',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(createFailure({ error }));
          })
        )
      )
    )
  );

  createSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(createSuccess),
      tap(action => {
        this.snackBar.open('Letter scheme created.', 'Close');
	this.router.navigate(['/user']);
      }),
    ),
    { dispatch: false }
  );

  update$ = createEffect(() =>
    this.actions$.pipe(
      ofType(update),
      exhaustMap(action =>
        this.letterSchemesService.update(action.newLetterScheme).pipe(
          map(letterScheme => updateSuccess({ newLetterScheme: action.newLetterScheme, letterScheme })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating',
              subject: 'letter scheme',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(updateFailure({ error }));
          })
        )
      )
    )
  );

  updateSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(updateSuccess),
      tap(action => {
        this.snackBar.open('Letter scheme updated.', 'Close');
	this.router.navigate(['/user']);
      }),
    ),
    { dispatch: false }
  );

  failure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoadFailure, createFailure, updateFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );
}
