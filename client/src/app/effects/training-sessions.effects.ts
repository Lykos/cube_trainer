import { Injectable } from '@angular/core';
import { Actions, ofType, concatLatestFrom, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { DeleteTrainingSessionConfirmationDialogComponent } from '@training/delete-training-session-confirmation-dialog/delete-training-session-confirmation-dialog.component';
import { OverrideAlgDialogComponent } from '@training/override-alg-dialog/override-alg-dialog.component';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { TrainingSessionAndCase } from '@training/training-session-and-case.model';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, switchMap, map, tap } from 'rxjs/operators';
import {
  initialLoad,
  initialLoadNop,
  initialLoadSuccess,
  initialLoadFailure,
  create,
  createSuccess,
  createFailure,
  deleteClick,
  dontDestroy,
  destroy,
  destroySuccess,
  destroyFailure,
  overrideAlgClick,
  dontOverrideAlg,
  overrideAlg,
  overrideAlgSuccess,
  overrideAlgFailure
} from '@store/training-sessions.actions';
import { selectIsInitialLoadFailureOrNotStarted } from '@store/training-sessions.selectors';
import { TrainingSessionsService } from '@training/training-sessions.service';
import { AlgOverridesService } from '@training/alg-overrides.service';
import { Router } from '@angular/router';
import { Store } from '@ngrx/store';

@Injectable()
export class TrainingSessionsEffects {
  constructor(
    private readonly actions$: Actions,
    private readonly store: Store,
    private readonly trainingSessionsService: TrainingSessionsService,
    private readonly algOverridesService: AlgOverridesService,
    private readonly dialog: MatDialog,
    private readonly snackBar: MatSnackBar,
    private readonly router: Router,
  ) {}

  initialLoad$ = createEffect(() =>
    this.actions$.pipe(
      ofType(initialLoad),
      concatLatestFrom(() => this.store.select(selectIsInitialLoadFailureOrNotStarted)),
      switchMap(([action, initialLoadNecessary]) => {
        if (!initialLoadNecessary) {
          return of(initialLoadNop());
        }
        return this.trainingSessionsService.list().pipe(
          map(trainingSessions => initialLoadSuccess({ trainingSessions })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'sessions',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(initialLoadFailure({ error }));
          })
        )
      })
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
        this.snackBar.open(`Session ${action.trainingSession.name} created.`, 'Close');
	this.router.navigate([`/training-sessions`]);
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
	this.router.navigate([`/training-sessions`]);
      }),
    ),
    { dispatch: false }
  );

  overrideAlgClick$ = createEffect(() =>
    this.actions$.pipe(
      ofType(overrideAlgClick),
      exhaustMap(action => {
        const trainingSessionAndCase: TrainingSessionAndCase = { trainingSession: action.trainingSession, trainingCase: action.trainingCase };
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
              subject: action.algOverride.trainingCase.caseName,
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
	this.snackBar.open(`Alg for ${action.algOverride.trainingCase.caseName} overriden.`, 'Close');
      }),
    ),
    { dispatch: false }
  );
}
