import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { DeleteModeConfirmationDialogComponent } from '../modes/delete-mode-confirmation-dialog/delete-mode-confirmation-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, exhaustMap, map, tap } from 'rxjs/operators';
import { initialLoad, initialLoadSuccess, initialLoadFailure, create, createSuccess, createFailure, deleteClick, dontDestroy, destroy, destroySuccess, destroyFailure } from '../state/modes.actions';
import { ModesService } from '../modes/modes.service';
import { Router } from '@angular/router';
 
@Injectable()
export class ModesEffects {
  constructor(
    private actions$: Actions,
    private readonly modesService: ModesService,
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
}
