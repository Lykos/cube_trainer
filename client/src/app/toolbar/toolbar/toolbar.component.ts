import { Component, OnInit } from '@angular/core';
import { selectUser } from '../../state/user.selectors';
import { MessagesService } from '../../users/messages.service';
import { User } from '../../users/user.model';
import { Optional, hasValue, mapOptional, orElse, ifPresent } from '../../utils/optional';
import { map, tap } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { Store } from '@ngrx/store';
import { initialLoad, logout } from '../../state/user.actions';

@Component({
  selector: 'cube-trainer-toolbar',
  templateUrl: './toolbar.component.html',
  styleUrls: ['./toolbar.component.css']
})
export class ToolbarComponent implements OnInit {
  readonly user$: Observable<Optional<User>>;
  unreadMessagesCount$: Observable<number>;

  constructor(private readonly store: Store) {
    this.user$ = this.store.select(selectUser);
  }

  get userName$() {
    return this.user$.pipe(map(user => orElse(mapOptional(user, u => u.name), '')));
  }

  get loggedIn$() {
    return this.user$.pipe(map(hasValue));
  }

  ngOnInit() {
    this.store.dispatch(initialLoad());
  }
  
  onLogout() {
    this.store.dispatch(logout());
  } 
}
