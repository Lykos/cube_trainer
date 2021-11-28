import { AngularTokenService, RegisterData } from 'angular-token';
import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { NewUser } from './new-user.model';
import { UserUpdate } from './user-update.model';
import { PasswordUpdate } from './password-update.model';
import { User } from './user.model';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { CookieConsentService } from '../shared/cookie-consent.service';

@Injectable({
  providedIn: 'root',
})
export class UsersService {
  constructor(private readonly rails: RailsService,
              private readonly tokenService: AngularTokenService,
              private readonly cookieConsentService: CookieConsentService) {}

  isNameOrEmailTaken(nameOrEmail: string): Observable<boolean> {
    return this.rails.ajax<boolean>(HttpVerb.Get, '/name_or_email_exists', {nameOrEmail});
  }

  create(newUser: NewUser): Observable<void> {
    const data: RegisterData = {
      login: newUser.email,
      password: newUser.password,
      passwordConfirmation: newUser.passwordConfirmation,
      name: newUser.name,
    };
    // Users have to consent to cookies during registration.
    return this.tokenService.registerAccount(data).pipe(
      tap(() => { this.cookieConsentService.turnOnConsent(); })
    );
  }

  login(email: string, password: string): Observable<User> {
    // Users have to consent to cookies during registration,
    // so we know they consented in the past if they log in.
    return this.tokenService.signIn({login: email, password}).pipe(
      tap(() => { this.cookieConsentService.turnOnConsent(); })
    );
  }

  logout() {
    return this.tokenService.signOut();
  }

  resetPassword(email: string) {
    return this.tokenService.resetPassword({login: email});
  }

  updatePassword(passwordUpdate: PasswordUpdate) {
    return this.tokenService.updatePassword(passwordUpdate);
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
