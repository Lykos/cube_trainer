import { Component, OnInit } from '@angular/core';
import { AuthenticationService } from '../users/authentication.service';
import { MessagesService } from '../users/messages.service';
import { Router } from '@angular/router';
import { User } from '../users/user';
import { Optional, none, hasValue, mapOptional, orElse } from '../utils/optional';

@Component({
  selector: 'cube-trainer-toolbar',
  templateUrl: './toolbar.component.html',
  styles: [`
.horizontal-spacer {
  flex: 1 1 auto;
}
`]
})
export class ToolbarComponent implements OnInit {
  user: Optional<User> = none;
  unreadMessagesCount: number | undefined = undefined;

  constructor(private readonly authenticationService: AuthenticationService,
	      private readonly messagesService: MessagesService,
	      private readonly router: Router) {
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

  onCubeTrainer() {
    this.router.navigate(['/modes']);
  }

  onUser() {
    this.router.navigate([`/users/${this.userId}`]);
  }

  onLogin() {
    this.router.navigate(['/login']);
  }

  onSignup() {
    this.router.navigate(['/signup']);
  }

  onLogout() {
    this.authenticationService.logout();
  }
}
