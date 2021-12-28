import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { DeleteModeConfirmationDialogComponent } from '../modes/delete-mode-confirmation-dialog/delete-mode-confirmation-dialog.component';
import { OverrideAlgDialogComponent } from '../modes/override-alg-dialog/override-alg-dialog.component';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { ModeAndCase } from '../modes/mode-and-case.model';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, map, tap } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, deleteClick, dontDestroy, destroy, destroySuccess, destroyFailure, overrideAlgClick, dontOverrideAlg, overrideAlg, overrideAlgSuccess, overrideAlgFailure } from '../state/modes.actions';
import { ModesService } from '../modes/modes.service';
import { AlgOverridesService } from '../modes/alg-overrides.service';
import { Router } from '@angular/router';
 
@Injectable()
export class ModesEffects {
  constructor(
    private actions$: Actions,
    private readonly modesService: ModesService,
    private readonly algOverridesService: AlgOverridesService,
    private readonly dialog: MatDialog,
    private readonly snackBar: MatSnackBar,
    private readonly router: Router,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(action =>
        this.modesService.list().pipe(
          map(modes => initialLoadSuccess({ modes })),
          catchError(error => of(initialLoadFailure({ error })))
        )
      )
    )
  );

  create$ = createEffect(() =>
    this.actions$.pipe(
      ofType(create),
      exhaustMap(action =>
        this.modesService.create(action.newMode).pipe(
          map(mode => createSuccess({ newMode: action.newMode, mode })),
          catchError(error => of(createFailure({ error })))
        )
      )
    )
  );

  createSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(createSuccess),
      tap(action => {
        this.snackBar.open(`Mode ${action.mode.name} created.`, 'Close');
	this.router.navigate([`/modes`]);
      }),
    ),
    { dispatch: false }
  );

  deleteClick$ = createEffect(() =>
    this.actions$.pipe(
      ofType(deleteClick),
      exhaustMap(action => {
        const dialogRef = this.dialog.open(DeleteModeConfirmationDialogComponent, { data: action.mode });
        return dialogRef.afterClosed().pipe(
          map(result => result ? destroy({ mode: action.mode }) : dontDestroy({ mode: action.mode }))
        );
      }),
    )
  );

  destroy$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroy),
      exhaustMap(action =>
        this.modesService.destroy(action.mode.id).pipe(
          map(mode => destroySuccess({ mode: action.mode })),
          catchError(error => of(destroyFailure({ error })))
        )
      )
    )
  );

  destroySuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroySuccess),
      tap(action => {
	this.snackBar.open(`Mode ${action.mode.name} deleted.`, 'Close');
	this.router.navigate([`/modes`]);
      }),
    ),
    { dispatch: false }
  );

  overrideAlgClick$ = createEffect(() =>
    this.actions$.pipe(
      ofType(overrideAlgClick),
      exhaustMap(action => {
        const modeAndCase: ModeAndCase = { mode: action.mode, casee: action.casee };
        const dialogRef = this.dialog.open(OverrideAlgDialogComponent, { data: modeAndCase });
        return dialogRef.afterClosed().pipe(
          map(algOverride => algOverride ? overrideAlg({ mode: action.mode, algOverride }) : dontOverrideAlg({ mode: action.mode }))
        );
      }),
    )
  );

  overrideAlg$ = createEffect(() =>
    this.actions$.pipe(
      ofType(overrideAlg),
      exhaustMap(action =>
        this.algOverridesService.createOrUpdate(action.mode.id, action.algOverride).pipe(
          map(mode => overrideAlgSuccess({ mode: action.mode, algOverride: action.algOverride })),
          catchError(httpResponseError => {
            const context = {
              action: 'overriding alg',
              subject: action.algOverride.casee.name,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(overrideAlgFailure({ error }));
          })
        )
      )
    )
  );

  overrideAlgFailure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(overrideAlgFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );

  overrideAlgSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(overrideAlgSuccess),
      tap(action => {
	this.snackBar.open(`Alg for ${action.algOverride.casee.name} overriden.`, 'Close');
      }),
    ),
    { dispatch: false }
  );
}
