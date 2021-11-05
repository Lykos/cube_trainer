import { SelectionModel } from '@angular/cdk/collections';
import { Component, OnInit, LOCALE_ID, Inject } from '@angular/core';
import { MessagesService } from './messages.service';
import { formatDate } from '@angular/common';
import { Message } from './message';
import { Router, ActivatedRoute } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Observable, zip } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-messages',
  templateUrl: './messages.component.html',
  styles: [`
table {
  width: 100%;
}
.mat-column-select {
  overflow: initial;
}
.unread-message {
  font-weight: bold;
}
`]
})
export class MessagesComponent implements OnInit {
  userId$: Observable<number>;
  messages: Message[] = [];
  columnsToDisplay = ['select', 'title', 'timestamp'];
  selection = new SelectionModel<Message>(true, []);

  constructor(private readonly messagesService: MessagesService,
	      @Inject(LOCALE_ID) private readonly locale: string,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly activatedRoute: ActivatedRoute) {
    this.userId$ = this.activatedRoute.params.pipe(map(p => p['userId']));
  }

  onClick(message: Message) {
    this.userId$.subscribe(userId => {
      this.router.navigate([`/users/${userId}/messages/${message.id}`]);
    });
  }

  ngOnInit() {
    this.update();
  }
    
  update() {
    this.userId$.subscribe(userId => {
      this.messagesService.list(userId).subscribe((messages: Message[]) =>
	this.messages = messages);
    });
  }

  onMarkAsReadSelected() {
    this.userId$.subscribe(modeId => {
      const observables = this.selection.selected.map(message =>
	this.messagesService.markAsRead(modeId, message.id));
      zip(...observables).subscribe((voids) => {
	this.selection.clear();
	this.snackBar.open(`Marked ${observables.length} messages as read!`, 'Close');
	this.update();
      });
    });
  }

  onDeleteSelected() {
    this.userId$.subscribe(modeId => {
      const observables = this.selection.selected.map(message =>
	this.messagesService.destroy(modeId, message.id));
      zip(...observables).subscribe((voids) => {
	this.selection.clear();
	this.snackBar.open(`Deleted ${observables.length} messages!`, 'Close');
	this.update();
      });
    });
  }

  /** Whether the number of selected elements matches the total number of rows. */
  get allSelected() {
    const numSelected = this.selection.selected.length;
    const numRows = this.messages.length;
    return numSelected === numRows;
  }

  /** Selects all rows if they are not all selected; otherwise clear selection. */
  masterToggle() {
    this.allSelected ?
      this.selection.clear() :
      this.messages.forEach(row => this.selection.select(row));
  }

  /** The label for the checkbox on the passed row */
  checkboxLabel(row?: Message): string {
    if (!row) {
      return `${this.allSelected ? 'select' : 'deselect'} all`;
    }
    return `${this.selection.isSelected(row) ? 'deselect' : 'select'} message from ${formatDate(row.timestamp.toDate(), 'short', this.locale)}`;
  }
}
