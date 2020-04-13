import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { BehaviorSubject, Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { User } from './user';
import { some, none, ofNull, mapOptional, Optional, hasValue } from '../utils/optional';

const LOCAL_STORAGE_USER_KEY = 'currentUser';

@Injectable({
  providedIn: 'root',
})
export class AuthenticationService {
  private currentUserSubject: BehaviorSubject<Optional<User>>;
  public readonly currentUser$: Observable<Optional<User>>;

  constructor(private readonly rails: RailsService) {
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
  
  login(username: string, password: string) {
    return this.rails.ajax<User>(HttpVerb.Post, '/login', {username, password})
      .pipe(map(user => {
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
    return this.rails.ajax<void>(HttpVerb.Post, '/logout', {});
  }
}
