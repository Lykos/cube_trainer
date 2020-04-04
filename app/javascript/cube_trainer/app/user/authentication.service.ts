import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { BehaviorSubject, Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { User } from './user';
import { some, ofNull, mapOptional, Optional, hasValue } from '../utils/optional';

const LOCAL_STORAGE_USER_KEY = 'currentUser';

@Injectable({
  providedIn: 'root',
})
export class AuthenticationService {
  private currentUserSubject: BehaviorSubject<Optional<User>>;
  public readonly currentUserObservable: Observable<Optional<User>>;

  constructor(private readonly rails: RailsService) {
    const unparsed = ofNull(localStorage.getItem(LOCAL_STORAGE_USER_KEY));
    const parsed = mapOptional(unparsed, s => JSON.parse(s));
    this.currentUserSubject = new BehaviorSubject<Optional<User>>(parsed);
    this.currentUserObservable = this.currentUserSubject.asObservable();
  }

  public get currentUser(): Optional<User> {
    return this.currentUserSubject.value;
  }

  public get loggedIn() {
    return hasValue(this.currentUser);
  }
  
  login(name: string, password: string) {
    return this.rails.ajax<void>(HttpVerb.Post, '/login', {name, password})
      .pipe(map((user: any) => {
        // store user details and jwt token in local storage to keep user logged in between page refreshes
        localStorage.setItem(LOCAL_STORAGE_USER_KEY, JSON.stringify(user));
        this.currentUserSubject.next(some(user));
        return user;
      }));
  }

  logout() {
    return this.rails.ajax<void>(HttpVerb.Post, '/logout', {});
  }

  create(name: string, password: string, passwordConfirmation: string, admin: boolean) {
    return this.rails.ajax<void>(HttpVerb.Post, 'users/create', {name, password, passwordConfirmation, admin});
  }
}
