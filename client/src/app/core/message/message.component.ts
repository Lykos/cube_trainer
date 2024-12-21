import { BackendActionErrorDialogComponent } from '@shared/backend-action-error-dialog/backend-action-error-dialog.component';
import { parseBackendActionError } from '@shared/parse-backend-action-error';
import { Component, OnInit } from '@angular/core';
import { MessagesService } from '../messages.service';
import { Message } from '../message.model';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';
import { map, mapTo, exhaustMap, shareReplay, switchMap } from 'rxjs/operators';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatCardModule } from '@angular/material/card';
import { AsyncPipe } from '@angular/common';
import { InstantPipe } from '../../shared/instant.pipe';

@Component({
  selector: 'cube-trainer-message',
  templateUrl: './message.component.html',
  imports: [AsyncPipe, InstantPipe, MatCardModule, MatDialogModule],
})
export class MessageComponent implements OnInit {
  message$: Observable<Message>;

  constructor(private readonly messagesService: MessagesService,
              private readonly dialog: MatDialog,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly activatedRoute: ActivatedRoute) {
    this.message$ = this.activatedRoute.params.pipe(
      map(p => +p['messageId']),
      switchMap(messageId => this.messagesService.show(messageId)),
      shareReplay(),
    );
  }

  onDelete() {
    this.message$.pipe(
      exhaustMap(message =>this.messagesService.destroy(message.id).pipe(mapTo(message)))
    ).subscribe(
      message => {
        this.snackBar.open(`Message '${message.title}' deleted!`, 'Close');
        this.router.navigate(['/messages']);
      },
      error => {
        const context = {
          action: 'deleting',
          subject: 'message',
        };
        this.dialog.open(BackendActionErrorDialogComponent, { data: parseBackendActionError(context, error) });
      }
    );
  }

  ngOnInit() {
    this.message$.pipe(
      exhaustMap(message => this.messagesService.markAsRead(message.id)),
    ).subscribe(
      () => {},
      error => {
        const context = {
          action: 'marking as read',
          subject: 'message',
        };
        this.dialog.open(BackendActionErrorDialogComponent, { data: parseBackendActionError(context, error) });
      }
    );
  }
}
