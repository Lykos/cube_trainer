import { Component, OnInit } from '@angular/core';
import { MessagesService } from './messages.service';
import { Message } from './message';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Component({
  selector: 'message',
  template: `
<mat-card>
  <mat-card-title>{{title}}</mat-card-title>
  <mat-card-content>
    {{body}}
  </mat-card-content>
  <mat-card-actions>
    <button mat-raised-button color="primary" (click)="onAll()">All Messages</button>
  </mat-card-actions>
</mat-card>
`
})
export class MessageComponent implements OnInit {
  userId$: Observable<number>;
  messageId$: Observable<number>;
  message: Message | undefined = undefined;

  constructor(private readonly messagesService: MessagesService,
	      private readonly router: Router,
	      private readonly activatedRoute: ActivatedRoute) {
    this.userId$ = this.activatedRoute.params.pipe(map(p => p.userId));
    this.messageId$ = this.activatedRoute.params.pipe(map(p => p.messageId));
  }

  get title() {
    return this.message?.title;
  }

  get body() {
    return this.message?.body;
  }

  onAll() {
    this.userId$.subscribe(userId => {    
      this.router.navigate([`/users/${userId}/messages`]);
    });
  }

  ngOnInit() {
    this.userId$.subscribe(userId => {
      this.messageId$.subscribe(messageId => {
	this.messagesService.show(userId, messageId).subscribe((message: Message) =>
	  this.message = message);
      });
    });
  }
}
