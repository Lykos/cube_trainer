import { Component } from '@angular/core';
import { AuthenticationService } from '../user/authentication.service';
import { Router } from '@angular/router';

@Component({
  selector: 'toolbar',
  template: `
<mat-toolbar color="primary">
  <ng-container *ngIf="loggedOut; else loggedIn">
    <button mat-button (click)="login()">
      Login
    </button>
    <button mat-button (click)="signup()">
      Sign Up
    </button>
  </ng-container>
  <ng-template #loggedIn>
    <button mat-button (click)="logout()">
      Logout
    </button>
  </ng-template>
</mat-toolbar>
`
})
export class ToolbarComponent {
  get loggedOut() {
    return !this.authenticationService.loggedIn;
  }

  constructor(private readonly authenticationService: AuthenticationService, private readonly router: Router) {}

  login() {
    this.router.navigate(['/login']);
  }

  signup() {
    this.router.navigate(['/signup']);
  }

  logout() {
    this.authenticationService.logout();
  }
}
