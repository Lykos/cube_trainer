import { map } from 'rxjs/operators';
import { hasValue } from '@utils/optional';
import { Component } from '@angular/core';
import { Store } from '@ngrx/store';
import { selectUser } from '@store/user.selectors';
import { Observable } from 'rxjs';

@Component({
  selector: 'cube-trainer-welcome',
  templateUrl: './welcome.component.html',
  styleUrls: ['./welcome.component.css']
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
