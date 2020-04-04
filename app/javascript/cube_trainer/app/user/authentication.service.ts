import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  private currentUserSubject: BehaviorSubject<User>;
  public currentUser: Observable<User>;

  constructor(private readonly rails: RailsService) {
    this.currentUserSubject = new BehaviorSubject<User>(JSON.parse(localStorage.getItem('currentUser')));
    this.currentUser = this.currentUserSubject.asObservable();
  }

  public get currentUserValue(): User {
    return this.currentUserSubject.value;
  }
  
  login(name: string, password: string) {
    return this.rails.ajax<void>(HttpVerb.Post, '/login', {name, password})
      .pipe(map(user => {
        // store user details and jwt token in local storage to keep user logged in between page refreshes
        localStorage.setItem('currentUser', JSON.stringify(user));
        this.currentUserSubject.next(user);
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
