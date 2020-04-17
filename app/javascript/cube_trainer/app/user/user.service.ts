import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { NewUser } from './new_user';
import { User } from './user';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  constructor(private readonly rails: RailsService) {}

  isUsernameOrEmailTaken(usernameOrEmail: string): Observable<boolean> {
    return this.rails.ajax<boolean>(HttpVerb.Get, '/user_name_or_email_exists', {usernameOrEmail}).pipe(map(answer => {console.log('exists', answer); return answer;}));
  }

  create(newUser: NewUser): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Post, '/users', {user: newUser});
  }

  show(userId: number): Observable<User> {
    return this.rails.ajax<User>(HttpVerb.Get, `/users/${userId}`, {});
  }
}
