import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { NewUser } from './new-user';
import { UserUpdate } from './user-update.model';
import { User } from './user';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class UsersService {
  constructor(private readonly rails: RailsService) {}

  isUsernameOrEmailTaken(usernameOrEmail: string): Observable<boolean> {
    return this.rails.ajax<boolean>(HttpVerb.Get, '/username_or_email_exists', {usernameOrEmail});
  }

  create(newUser: NewUser): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Post, '/users', {user: newUser});
  }

  update(user: User, userUpdate: UserUpdate): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Patch, `/users/${user.id}`, {user: userUpdate});
  }

  show(userId: number): Observable<User> {
    return this.rails.ajax<User>(HttpVerb.Get, `/users/${userId}`, {});
  }
}
