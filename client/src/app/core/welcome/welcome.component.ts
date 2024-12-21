import { map } from 'rxjs/operators';
import { hasValue } from '@utils/optional';
import { Component } from '@angular/core';
import { Store } from '@ngrx/store';
import { selectUser } from '@store/user.selectors';
import { Observable } from 'rxjs';

import { LoggedInWelcomeComponent } from '../logged-in-welcome/logged-in-welcome.component';
import { LoggedOutWelcomeComponent } from '../logged-out-welcome/logged-out-welcome.component';
import { AsyncPipe } from '@angular/common';

@Component({
  selector: 'cube-trainer-welcome',
  templateUrl: './welcome.component.html',
  styleUrls: ['./welcome.component.css'],
  imports: [LoggedInWelcomeComponent, LoggedOutWelcomeComponent, AsyncPipe],
})
export class WelcomeComponent {
  readonly loggedIn$: Observable<{ readonly value: boolean }>;

  constructor(private readonly store: Store) {
    this.loggedIn$ = this.store.select(selectUser).pipe(
      map(hasValue),
      map(value => ({ value })),
    );
  }
}
