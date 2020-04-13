import { Component, OnInit } from '@angular/core';
import { MessagesService } from './messages.service';
import { Message } from './message';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'messages',
  template: `
<div>
  <h2>Messages</h2>
  <div>
    <table mat-table [dataSource]="messages">
      <ng-container matColumnDef="timestamp">
        <th mat-header-cell *matHeaderCellDef> Timestamp </th>
        <td mat-cell *matCellDef="let message"> {{message.timestamp | instant}} </td>
      </ng-container>
      <mat-text-column name="title"></mat-text-column>
      <mat-text-column name="read"></mat-text-column>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let message; columns: columnsToDisplay" (click)="onClick(message)"></tr>
    </table>
  </div>
</div>
`
})
export class MessagesComponent implements OnInit {
  userId$: Observable<number>;
  messages: Message[] = [];
  columnsToDisplay = ['timestamp', 'title', 'read'];

  constructor(private readonly messagesService: MessagesService,
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
    this.userId$.subscribe(userId => {
      this.messagesService.list(userId).subscribe((messages: Message[]) =>
	this.messages = messages);
    });
  }
}
