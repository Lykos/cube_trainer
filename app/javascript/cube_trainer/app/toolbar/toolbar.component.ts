import { Component } from '@angular/core';
import { UserService } from '../user/user.service';
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
  loggedIn = false;

  get loggedOut() {
    return !this.loggedIn;
  }

  constructor(private readonly userService: UserService, private readonly router: Router) {}

  login() {
    this.router.navigate(['/login']);
  }

  signup() {
    this.router.navigate(['/signup']);
  }

  logout() {
    this.loggedIn = false;
    this.userService.logout();
  }
}
