import { AngularTokenService, RegisterData } from 'angular-token';
import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { NewUser } from './new-user.model';
import { UserUpdate } from './user-update.model';
import { User } from './user.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class UsersService {
  constructor(private readonly rails: RailsService,
              private readonly tokenService: AngularTokenService) {}

  isUsernameOrEmailTaken(usernameOrEmail: string): Observable<boolean> {
    return this.rails.ajax<boolean>(HttpVerb.Get, '/username_or_email_exists', {usernameOrEmail});
  }

  create(newUser: NewUser): Observable<void> {
    const data: RegisterData = {
      login: newUser.email,
      password: newUser.password,
      passwordConfirmation: newUser.passwordConfirmation,
      name: newUser.name,
    };
    return this.tokenService.registerAccount(data);
  }

  login(email: string, password: string) {
    return this.tokenService.signIn({login: email, password});
  }

  logout() {
    return this.tokenService.signOut();
  }

  update(userUpdate: UserUpdate): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Patch, '/user', {user: userUpdate});
  }

  show(): Observable<User> {
    return this.rails.ajax<User>(HttpVerb.Get, '/user', {});
  }

  destroy(): Observable<void> {
    return this.tokenService.deleteAccount();
  }
}
