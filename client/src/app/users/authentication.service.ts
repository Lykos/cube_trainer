import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { User } from './user.model';
import { AngularTokenService } from 'angular-token';
import { some, none, ofNull, mapOptional, Optional, hasValue } from '../utils/optional';
import { map } from 'rxjs/operators';

const LOCAL_STORAGE_USER_KEY = 'currentUser';

@Injectable({
  providedIn: 'root',
})
export class AuthenticationService {
  private currentUserSubject: BehaviorSubject<Optional<User>>;
  public readonly currentUser$: Observable<Optional<User>>;

  constructor(private readonly tokenService: AngularTokenService) {
    const unparsed = ofNull(localStorage.getItem(LOCAL_STORAGE_USER_KEY));
    const parsed = mapOptional(unparsed, s => JSON.parse(s));
    this.currentUserSubject = new BehaviorSubject<Optional<User>>(parsed);
    this.currentUser$ = this.currentUserSubject.asObservable();
  }

  public get currentUser(): Optional<User> {
    return this.currentUserSubject.value;
  }

  public get loggedIn() {
    return hasValue(this.currentUser);
  }
  
  login(usernameOrEmail: string, password: string) {
    return this.tokenService.signIn({login: usernameOrEmail, password})
      .pipe(map((user: User) => {
        // store user details and jwt token in local storage to keep user logged in between page refreshes
        localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(user));
        this.currentUserSubject.next(some(user));
        return user;
      }));
  }

  logout() {
    // remove user from local storage to log user out
    localStorage.removeItem(LOCAL_STORAGE_USER_KEY);
    this.currentUserSubject.next(none);
    return this.tokenService.signOut();
  }
}
