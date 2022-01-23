import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { MatSnackBar } from '@angular/material/snack-bar';
import { of } from 'rxjs';
import { catchError, exhaustMap, map, tap } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, update, updateSuccess, updateFailure } from '@store/color-scheme.actions';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { ColorSchemesService } from '@training/color-schemes.service';
import { Router } from '@angular/router';
 
@Injectable()
export class ColorSchemeEffects {
  constructor(
    private actions$: Actions,
    private readonly dialog: MatDialog,
    private readonly colorSchemesService: ColorSchemesService,
    private readonly snackBar: MatSnackBar,
    private readonly router: Router,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(action =>
        this.colorSchemesService.show().pipe(
          map(colorScheme => initialLoadSuccess({ colorScheme })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'color scheme',
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
        this.colorSchemesService.create(action.newColorScheme).pipe(
          map(colorScheme => createSuccess({ newColorScheme: action.newColorScheme, colorScheme })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating',
              subject: 'color scheme',
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
        this.snackBar.open('Color scheme created.', 'Close');
	this.router.navigate(['/user']);
      }),
    ),
    { dispatch: false }
  );

  update$ = createEffect(() =>
    this.actions$.pipe(
      ofType(update),
      exhaustMap(action =>
        this.colorSchemesService.update(action.newColorScheme).pipe(
          map(colorScheme => updateSuccess({ newColorScheme: action.newColorScheme, colorScheme })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating',
              subject: 'color scheme',
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
        this.snackBar.open('Color scheme updated.', 'Close');
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
