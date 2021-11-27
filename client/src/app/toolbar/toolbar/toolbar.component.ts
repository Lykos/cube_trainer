import { Component, OnInit } from '@angular/core';
import { UsersService } from '../../users/users.service';
import { MessagesService } from '../../users/messages.service';
import { User } from '../../users/user.model';
import { Optional, some, none, hasValue, mapOptional, orElse } from '../../utils/optional';
import { map, catchError } from 'rxjs/operators';
import { of } from 'rxjs';

@Component({
  selector: 'cube-trainer-toolbar',
  templateUrl: './toolbar.component.html',
  styleUrls: ['./toolbar.component.css']
})
export class ToolbarComponent implements OnInit {
  user: Optional<User> = none;
  unreadMessagesCount: number | undefined = undefined;

  constructor(private readonly usersService: UsersService,
	      private readonly messagesService: MessagesService) {
  }

  get unreadMessagesBadge() {
    return this.unreadMessagesCount == 0 ? undefined : this.unreadMessagesCount;
  }

  get userName() {
    return orElse(mapOptional(this.user, u => u.name), '');
  }

  get loggedIn() {
    return hasValue(this.user);
  }

  get numBadges() {
    return this.unreadMessagesCount;
  }

  ngOnInit() {
    this.usersService.show().pipe(
      map(user => some(user)),
      catchError(err => of(none)),
    ).subscribe(
      (user) => {
	this.user = user;
	mapOptional(user, u => {
	  this.messagesService.countUnread().subscribe(count => this.unreadMessagesCount = count);
	});
      });
  }
}
