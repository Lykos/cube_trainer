import { Component, OnInit } from '@angular/core';
import { UsersService } from '../../users/users.service';
import { selectUser } from '../../state/user.selectors';
import { MessagesService } from '../../users/messages.service';
import { User } from '../../users/user.model';
import { Optional, some, none, hasValue, mapOptional, orElse } from '../../utils/optional';
import { map, catchError } from 'rxjs/operators';
import { of } from 'rxjs';
import { Router } from '@angular/router';
import { Store } from '@ngrx/store';

@Component({
  selector: 'cube-trainer-toolbar',
  templateUrl: './toolbar.component.html',
  styleUrls: ['./toolbar.component.css']
})
export class ToolbarComponent implements OnInit {
  readonly user$: Observable<Optional<User>>;
  unreadMessagesCount: number | undefined = undefined;

  constructor(private readonly messagesService: MessagesService,
              private readonly router: Router,
              private readonly store: Store) {
    this.user$ = this.store.select(selectUser);
  }

  get unreadMessagesBadge() {
    return this.unreadMessagesCount == 0 ? undefined : this.unreadMessagesCount;
  }

  get userName$() {
    return user$.pipe(map(user => orElse(mapOptional(user, u => u.name), '')));
  }

  get loggedIn$() {
    return this.user.pipe(map(hasValue));
  }

  get numBadges() {
    return this.unreadMessagesCount;
  }

  onLogout() {
    this.usersService.logout().subscribe(() => {
      this.user = none;
      this.router.navigate(['/logged_out']);
    });
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
