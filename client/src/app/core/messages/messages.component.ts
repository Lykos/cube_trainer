import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { SelectionModel } from '@angular/cdk/collections';
import { MatDialog } from '@angular/material/dialog';
import { Component, LOCALE_ID, Inject } from '@angular/core';
import { RouterModule } from '@angular/router';
import { MessagesService } from '../messages.service';
import { formatDate, AsyncPipe } from '@angular/common';
import { Message } from '../message.model';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Observable, zip } from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTableModule } from '@angular/material/table';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { BackendActionErrorPipe } from '../../shared/backend-action-error.pipe';
import { BackendActionLoadErrorComponent } from '../../shared/backend-action-load-error/backend-action-load-error.component';
import { ErrorPipe } from '../../shared/error.pipe';
import { InstantPipe } from '../../shared/instant.pipe';
import { OrErrorPipe } from '../../shared/or-error.pipe';
import { ValuePipe } from '../../shared/value.pipe';

@Component({
  selector: 'cube-trainer-messages',
  templateUrl: './messages.component.html',
  styleUrls: ['./messages.component.css'],
  imports: [
    AsyncPipe,
    BackendActionErrorPipe,
    BackendActionLoadErrorComponent,
    ErrorPipe,
    InstantPipe,
    OrErrorPipe,
    ValuePipe,
    MatProgressSpinnerModule,
    MatTableModule,
    RouterModule,
    MatCheckboxModule,
  ],
})
export class MessagesComponent {
  messages$: Observable<Message[]>;
  columnsToDisplay = ['select', 'title', 'timestamp'];
  selection = new SelectionModel<Message>(true, []);
  /** Whether the number of selected elements matches the total number of rows. */
  allSelected$: Observable<{ value: boolean }>;

  constructor(private readonly messagesService: MessagesService,
              private readonly dialog: MatDialog,
	      @Inject(LOCALE_ID) private readonly locale: string,
	      private readonly snackBar: MatSnackBar) {
    this.messages$ = this.messagesService.list().pipe(shareReplay());
    this.allSelected$ = this.messages$.pipe(
      map(ms => { return { value: this.selection.selected.length === ms.length }; }),
      shareReplay(),
    );
  }
    
  update() {
    this.messages$ = this.messagesService.list().pipe(shareReplay());
  }

  onMarkAsReadSelected() {
    const observables = this.selection.selected.map(
      message => this.messagesService.markAsRead(message.id));
    zip(...observables).subscribe(voids => {
      this.selection.clear();
      this.snackBar.open(`Marked ${observables.length} messages as read!`, 'Close');
      this.update();
    },
    error => {
      const context = {
        action: 'marking as read',
        subject: `${observables.length} messages`,
      };
      this.dialog.open(BackendActionErrorDialogComponent, { data: parseBackendActionError(context, error) });
    });
  }

  onDeleteSelected() {
    const observables = this.selection.selected.map(
      message => this.messagesService.destroy(message.id));
    zip(...observables).subscribe((voids) => {
      this.selection.clear();
      this.snackBar.open(`Deleted ${observables.length} messages!`, 'Close');
      this.update();
    },
    error => {
      const context = {
        action: 'marking as read',
        subject: `${observables.length} messages`,
      };
      this.dialog.open(BackendActionErrorDialogComponent, { data: parseBackendActionError(context, error) });
    });
  }

  /** Selects all rows if they are not all selected; otherwise clear selection. */
  masterToggle(messages: readonly Message[], allSelected: boolean) {
    allSelected ?
      this.selection.clear() :
      messages.forEach(row => this.selection.select(row));
  }

  /** The label for the checkbox on the passed row */
  checkboxLabel(allSelected: boolean, row?: Message): string {
    if (!row) {
      return `${allSelected ? 'select' : 'deselect'} all`;
    }
    return `${this.selection.isSelected(row) ? 'deselect' : 'select'} message from ${formatDate(row.timestamp.toDate(), 'short', this.locale)}`;
  }

  routerLink(message: Message) {
    return `/messages/${message.id}`;
  }

  get context() {
    return {
      action: 'loading',
      subject: 'messages',
    };
  }
}
