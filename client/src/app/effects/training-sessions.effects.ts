import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { DeleteTrainingSessionConfirmationDialogComponent } from '@training/delete-training-session-confirmation-dialog/delete-training-session-confirmation-dialog.component';
import { OverrideAlgDialogComponent } from '@training/override-alg-dialog/override-alg-dialog.component';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { TrainingSessionAndCase } from '@training/training-session-and-case.model';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, map, tap } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, deleteClick, dontDestroy, destroy, destroySuccess, destroyFailure, overrideAlgClick, dontOverrideAlg, overrideAlg, overrideAlgSuccess, overrideAlgFailure } from '@store/training-sessions.actions';
import { TrainingSessionsService } from '@training/training-sessions.service';
import { AlgOverridesService } from '@training/alg-overrides.service';
import { Router } from '@angular/router';

@Injectable()
export class TrainingSessionsEffects {
  constructor(
    private actions$: Actions,
    private readonly trainingSessionsService: TrainingSessionsService,
    private readonly algOverridesService: AlgOverridesService,
    private readonly dialog: MatDialog,
    private readonly snackBar: MatSnackBar,
    private readonly router: Router,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      exhaustMap(action =>
        this.trainingSessionsService.list().pipe(
          map(trainingSessions => initialLoadSuccess({ trainingSessions })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'training sessions',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(initialLoadFailure({ error }));
          })
        )
      )
    )
  );

  // Failure for initialLoad has no effect, it shows a message at the component where the training sessions are rendered.
  
  create$ = createEffect(() =>
    this.actions$.pipe(
      ofType(create),
      exhaustMap(action =>
        this.trainingSessionsService.create(action.newTrainingSession).pipe(
          map(trainingSession => createSuccess({ newTrainingSession: action.newTrainingSession, trainingSession })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating',
              subject: action.newTrainingSession.name,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(createFailure({ error }));
          })
        )
      )
    )
  );

  createFailure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(createFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );

  createSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(createSuccess),
      tap(action => {
        this.snackBar.open(`Training session ${action.trainingSession.name} created.`, 'Close');
	this.router.navigate([`/trainingSessions`]);
      }),
    ),
    { dispatch: false }
  );

  deleteClick$ = createEffect(() =>
    this.actions$.pipe(
      ofType(deleteClick),
      exhaustMap(action => {
        const dialogRef = this.dialog.open(DeleteTrainingSessionConfirmationDialogComponent, { data: action.trainingSession });
        return dialogRef.afterClosed().pipe(
          map(result => result ? destroy({ trainingSession: action.trainingSession }) : dontDestroy({ trainingSession: action.trainingSession }))
        );
      }),
    )
  );

  destroy$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroy),
      exhaustMap(action =>
        this.trainingSessionsService.destroy(action.trainingSession.id).pipe(
          map(trainingSession => destroySuccess({ trainingSession: action.trainingSession })),
          catchError(httpResponseError => {
            const context = {
              action: 'deleting',
              subject: action.trainingSession.name,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(destroyFailure({ error }));
          })
        )
      )
    )
  );

  destroyFailure$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroyFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );

  destroySuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(destroySuccess),
      tap(action => {
	this.snackBar.open(`TrainingSession ${action.trainingSession.name} deleted.`, 'Close');
	this.router.navigate([`/trainingSessions`]);
      }),
    ),
    { dispatch: false }
  );

  overrideAlgClick$ = createEffect(() =>
    this.actions$.pipe(
      ofType(overrideAlgClick),
      exhaustMap(action => {
        const trainingSessionAndCase: TrainingSessionAndCase = { trainingSession: action.trainingSession, casee: action.casee };
        const dialogRef = this.dialog.open(OverrideAlgDialogComponent, { data: trainingSessionAndCase });
        return dialogRef.afterClosed().pipe(
          map(algOverride => algOverride ? overrideAlg({ trainingSession: action.trainingSession, algOverride }) : dontOverrideAlg({ trainingSession: action.trainingSession }))
        );
      }),
    )
  );

  overrideAlg$ = createEffect(() =>
    this.actions$.pipe(
      ofType(overrideAlg),
      exhaustMap(action =>
        this.algOverridesService.createOrUpdate(action.trainingSession.id, action.algOverride).pipe(
          map(trainingSession => overrideAlgSuccess({ trainingSession: action.trainingSession, algOverride: action.algOverride })),
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
