import { Component, OnInit } from '@angular/core';
import { MessagesService } from '../messages.service';
import { Message } from '../message.model';
import { Router, ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { MatSnackBar } from '@angular/material/snack-bar';
import { map } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-message',
  templateUrl: './message.component.html'
})
export class MessageComponent implements OnInit {
  userId$: Observable<number>;
  messageId$: Observable<number>;
  message: Message | undefined = undefined;

  constructor(private readonly messagesService: MessagesService,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly activatedRoute: ActivatedRoute) {
    this.userId$ = this.activatedRoute.params.pipe(map(p => p['userId']));
    this.messageId$ = this.activatedRoute.params.pipe(map(p => p['messageId']));
  }

  get timestamp() {
    return this.message?.timestamp;
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

  onDelete() {
    this.userId$.subscribe(userId => {
      this.messageId$.subscribe(messageId => {
	this.messagesService.destroy(userId, messageId).subscribe(() => {
	  this.snackBar.open(`Message ${this.message!.title} deleted!`, 'Close');
	  this.router.navigate([`/users/${userId}/messages`]);
	});
      });      
    });
  }

  ngOnInit() {
    this.userId$.subscribe(userId => {
      this.messageId$.subscribe(messageId => {
	this.messagesService.show(userId, messageId).subscribe((message: Message) =>
	  this.message = message);
	this.messagesService.markAsRead(userId, messageId).subscribe(r => {});
      });
    });
  }
}
