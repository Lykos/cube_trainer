import { SelectionModel } from '@angular/cdk/collections';
import { Component, OnInit, LOCALE_ID, Inject } from '@angular/core';
import { MessagesService } from './messages.service';
import { formatDate } from '@angular/common';
import { Message } from './message';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable, zip } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'messages',
  template: `
<div>
  <h2>Messages</h2>
  <div>
    <table mat-table class="mat-elevation-z2" [dataSource]="messages">
      <ng-container matColumnDef="select">
        <th mat-header-cell *matHeaderCellDef>
          <mat-checkbox (change)="$event ? masterToggle() : null"
                        [checked]="selection.hasValue() && allSelected"
                        [indeterminate]="selection.hasValue() && !allSelected"
                        [aria-label]="checkboxLabel()">
          </mat-checkbox>
        </th>
        <td mat-cell *matCellDef="let result">
          <mat-checkbox (click)="$event.stopPropagation()"
                        (change)="$event ? selection.toggle(result) : null"
                        [checked]="selection.isSelected(result)"
                        [aria-label]="checkboxLabel(result)">
          </mat-checkbox>
        </td>
      </ng-container>
      <mat-text-column name="title"></mat-text-column>
      <ng-container matColumnDef="timestamp">
        <th mat-header-cell *matHeaderCellDef> Timestamp </th>
        <td mat-cell *matCellDef="let message"> {{message.timestamp | instant}} </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr
        mat-row
        *matRowDef="let message; columns: columnsToDisplay"
        (click)="onClick(message)"
        [class.read-message]="message.read"
        [class.unread-message]="!message.read">
      </tr>
    </table>
    <button #deleteButton mat-fab (click)="onDeleteSelected()" *ngIf="selection.hasValue()">
      <span class="material-icons">delete</span>
    </button>
    <button #deleteButton mat-fab (click)="onMarkAsReadSelected()" *ngIf="selection.hasValue()">
      <span class="material-icons">check_circle</span>
    </button>
  </div>
</div>
`,
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
  private selection = new SelectionModel<Message>(true, []);

  constructor(private readonly messagesService: MessagesService,
	      @Inject(LOCALE_ID) private readonly locale: string,
	      private readonly router: Router,
	      private readonly activatedRoute: ActivatedRoute) {
    this.userId$ = this.activatedRoute.params.pipe(map(p => p.userId));
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
