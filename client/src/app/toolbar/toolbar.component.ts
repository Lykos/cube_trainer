import { Component, OnInit } from '@angular/core';
import { AuthenticationService } from '../users/authentication.service';
import { MessagesService } from '../users/messages.service';
import { User } from '../users/user.model';
import { Optional, none, hasValue, mapOptional, orElse } from '../utils/optional';

@Component({
  selector: 'cube-trainer-toolbar',
  templateUrl: './toolbar.component.html',
  styleUrls: ['./toolbar.component.css']
})
export class ToolbarComponent implements OnInit {
  user: Optional<User> = none;
  unreadMessagesCount: number | undefined = undefined;

  constructor(private readonly authenticationService: AuthenticationService,
	      private readonly messagesService: MessagesService) {
  }

  get unreadMessagesBadge() {
    return this.unreadMessagesCount == 0 ? undefined : this.unreadMessagesCount;
  }

  get userName() {
    return orElse(mapOptional(this.user, u => u.name), '');
  }

  get userId() {
    return orElse(mapOptional(this.user, u => u.id), 0);
  }

  get userPath() {
    return `/users/${this.userId}`;
  }

  get loggedIn() {
    return hasValue(this.user);
  }

  get numBadges() {
    return this.unreadMessagesCount;
  }

  ngOnInit() {
    this.authenticationService.currentUser$.subscribe(
      (user) => {
	this.user = user;
	mapOptional(user, u => {
	  this.messagesService.countUnread(u.id).subscribe(count => this.unreadMessagesCount = count);
	});
      });
  }
}
