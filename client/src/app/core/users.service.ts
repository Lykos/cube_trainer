import { AngularTokenService } from '@angular-token/angular-token.service';
import { RegisterData } from '@angular-token/angular-token.model';
import { RailsService } from '@core/rails.service';
import { Injectable } from '@angular/core';
import { NewUser } from './new-user.model';
import { UserUpdate } from './user-update.model';
import { PasswordUpdate } from './password-update.model';
import { PasswordChange } from './password-change.model';
import { User } from './user.model';
import { Credentials } from './credentials.model';
import { Observable } from 'rxjs';
import { filter, tap, map, mapTo } from 'rxjs/operators';
import { CookieConsentService } from './cookie-consent.service';

@Injectable({
  providedIn: 'root',
})
export class UsersService {
  constructor(private readonly rails: RailsService,
              private readonly tokenService: AngularTokenService,
              private readonly cookieConsentService: CookieConsentService) {}
  create(newUser: NewUser): Observable<void> {
    const data: RegisterData = {
      login: newUser.email,
      password: newUser.password,
      passwordConfirmation: newUser.passwordConfirmation,
      name: newUser.name,
    };
    return this.tokenService.registerAccount(data).pipe(
      tap(() => {
	// Users have to consent to cookies during registration,
	// so we can assume they consented if they register.
	this.cookieConsentService.turnOnConsent();
      }),
      mapTo(undefined),
    );
  }

  login(credentials: Credentials): Observable<User> {
    const params = { login: credentials.email, password: credentials.password };
    return this.tokenService.signIn(params).pipe(
      map(response => response.data),
      filter(user => !!user),
      map(user => user!),
      map(user => ({ id: user.id, email: user.login, name: user.name })),
      tap((user) => {
        // Users have to consent to cookies during registration,
        // so we know they consented in the past if they log in.
        this.cookieConsentService.turnOnConsent();
      }),
    );
  }

  logout() {
    return this.tokenService.signOut();
  }

  resetPassword(email: string) {
    return this.tokenService.resetPassword({login: email});
  }

  // This version is for password reset flows and it doesn't
  // need the users current password. But the backend will only
  // accept it if the user has previously clicked on a reset
  // password link that he received by mail.
  updatePassword(passwordUpdate: PasswordUpdate) {
    return this.tokenService.updatePassword(passwordUpdate);
  }

  // This version always works for logged in users,
  // but users have to supply their current password.
  changePassword(passwordChange: PasswordChange) {
    return this.tokenService.updatePassword(passwordChange);
  }

  update(userUpdate: UserUpdate): Observable<void> {
    return this.rails.patch<void>('/auth', userUpdate);
  }

  show(): Observable<User> {
    return this.rails.get<User>('/user', {});
  }

  destroy(): Observable<void> {
    return this.tokenService.deleteAccount().pipe(mapTo(undefined));
  }
}
