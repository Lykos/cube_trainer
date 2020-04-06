import { Component } from '@angular/core';
import { AuthenticationService } from '../user/authentication.service';
import { Router } from '@angular/router';
import { hasValue } from '../utils/optional';

@Component({
  selector: 'toolbar',
  template: `
<mat-toolbar color="primary">
  <ng-container *ngIf="!loggedIn; else loggedInBlock">
    <button mat-button (click)="onLogin()">
      Login
    </button>
    <button mat-button (click)="onSignup()">
      Sign Up
    </button>
  </ng-container>
  <ng-template #loggedInBlock>
    <button mat-button (click)="onLogout()">
      Logout
    </button>
  </ng-template>
</mat-toolbar>
`
})
export class ToolbarComponent {
  loggedIn = false;

  constructor(private readonly authenticationService: AuthenticationService,
	      private readonly router: Router) {
    this.authenticationService.currentUserObservable.subscribe(
      (user) => { this.loggedIn = hasValue(user) });
  }

  onLogin() {
    this.router.navigate(['/login']);
  }

  onSignup() {
    this.router.navigate(['/signup']);
  }

  onLogout() {
    this.authenticationService.logout();
  }
}
