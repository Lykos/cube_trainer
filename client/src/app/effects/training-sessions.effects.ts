import { Injectable } from '@angular/core';
import { concatLatestFrom } from '@ngrx/operators';
import { Actions, ofType, createEffect } from '@ngrx/effects';
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
  loadOne,
  loadOneSuccess,
  loadOneFailure,
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
  createAlgOverride,
  createAlgOverrideSuccess,
  createAlgOverrideFailure,
  updateAlgOverride,
  updateAlgOverrideSuccess,
  updateAlgOverrideFailure,
  setAlgClick,
  dontSetAlg,
  setAlg,
  setAlgSuccess,
  setAlgFailure,
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
          // TODO: If it's recent, return this.
          of(initialLoadNop());
        }
        return this.trainingSessionsService.list().pipe(
          map(trainingSessionSummaries => initialLoadSuccess({ trainingSessionSummaries })),
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

  loadOne$ = createEffect(() =>
    this.actions$.pipe(
      ofType(loadOne),
      switchMap(action => {
        // TODO: If it was done recently, return this.
        return this.trainingSessionsService.show(action.trainingSessionId).pipe(
          map(trainingSession => loadOneSuccess({ trainingSession })),
          catchError(httpResponseError => {
            const context = {
              action: 'loading',
              subject: 'session',
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(loadOneFailure({ error }));
          })
        )
      })
    )
  );

  create$ = createEffect(() =>
    this.actions$.pipe(
      ofType(create),
      exhaustMap(action =>
        this.trainingSessionsService.create(action.newTrainingSession).pipe(
          map(trainingSessionSummary => createSuccess({ newTrainingSession: action.newTrainingSession, trainingSessionSummary })),
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

  createSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(createSuccess),
      tap(action => {
        this.snackBar.open(`Session ${action.trainingSessionSummary.name} created.`, 'Close');
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
          map(newAlgOverride => newAlgOverride ? overrideAlg({ trainingSession: action.trainingSession, newAlgOverride }) : dontOverrideAlg({ trainingSession: action.trainingSession }))
        );
      }),
    )
  );

  overrideAlg$ = createEffect(() =>
    this.actions$.pipe(
      ofType(overrideAlg),
      map(action => {
	const algOverrideSource = action.newAlgOverride.trainingCase.algSource;
	if (algOverrideSource && algOverrideSource.tag === 'overridden') {
	  return updateAlgOverride({ ...action, algOverrideId: algOverrideSource.algOverrideId });
	} else {
	  return createAlgOverride({ ...action });
	}
      }),
    )
  );

  createAlgOverride$ = createEffect(() =>
    this.actions$.pipe(
      ofType(createAlgOverride),
      exhaustMap(action =>
        this.algOverridesService.create(action.trainingSession.id, action.newAlgOverride).pipe(
          map(algOverride => createAlgOverrideSuccess({ trainingSession: action.trainingSession, algOverride })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating alg override',
              subject: action.newAlgOverride.trainingCase.casee.name,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(createAlgOverrideFailure({ error }));
          })
        )
      )
    )
  );

  updateAlgOverride$ = createEffect(() =>
    this.actions$.pipe(
      ofType(updateAlgOverride),
      exhaustMap(action =>
        this.algOverridesService.update(action.trainingSession.id, action.algOverrideId, action.newAlgOverride.alg).pipe(
          map(algOverride => updateAlgOverrideSuccess({ trainingSession: action.trainingSession, algOverride })),
          catchError(httpResponseError => {
            const context = {
              action: 'creating alg override',
              subject: action.newAlgOverride.trainingCase.casee.name,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(updateAlgOverrideFailure({ error }));
          })
        )
      )
    )
  );

  overrideAlgSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(createAlgOverrideSuccess, updateAlgOverrideSuccess),
      tap(action => {
	this.snackBar.open(`Alg for ${action.algOverride.casee.name} overridden.`, 'Close');
      }),
    ),
    { dispatch: false }
  );

  setAlgClick$ = createEffect(() =>
    this.actions$.pipe(
      ofType(setAlgClick),
      exhaustMap(action => {
        const trainingSessionAndCase: TrainingSessionAndCase = { trainingSession: action.trainingSession, trainingCase: action.trainingCase };
        const dialogRef = this.dialog.open(OverrideAlgDialogComponent, { data: trainingSessionAndCase });
        return dialogRef.afterClosed().pipe(
          map(newAlgOverride => newAlgOverride ? setAlg({ trainingSession: action.trainingSession, newAlgOverride }) : dontSetAlg({ trainingSession: action.trainingSession }))
        );
      }),
    )
  );

  setAlg$ = createEffect(() =>
    this.actions$.pipe(
      ofType(setAlg),
      exhaustMap(action =>
        this.algOverridesService.create(action.trainingSession.id, action.newAlgOverride).pipe(
          map(algOverride => setAlgSuccess({ trainingSession: action.trainingSession, algOverride })),
          catchError(httpResponseError => {
            const context = {
              action: 'overriding alg',
              subject: action.newAlgOverride.trainingCase.casee.name,
            }
            const error = parseBackendActionError(context, httpResponseError);
            return of(setAlgFailure({ error }));
          })
        )
      )
    )
  );

  setAlgSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(setAlgSuccess),
      tap(action => {
	this.snackBar.open(`Alg for ${action.algOverride.casee.name} set.`, 'Close');
      }),
    ),
    { dispatch: false }
  );

  failure$ = createEffect(() =>
    this.actions$.pipe(
      // Failure for initialLoad has no effect,
      // it shows a message at the component where the training sessions are rendered.
      ofType(loadOneFailure, createFailure, destroyFailure, createAlgOverrideFailure, updateAlgOverrideFailure, setAlgFailure),
      tap(action => {
        this.dialog.open(BackendActionErrorDialogComponent, { data: action.error });
      }),
    ),
    { dispatch: false }
  );
  
}
