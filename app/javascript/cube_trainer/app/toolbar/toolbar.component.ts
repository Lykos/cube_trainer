import { Component } from '@angular/core';
import { UserService } from '../user/user.service';

@Component({
  selector: 'toolbar',
  template: `
<mat-toolbar>
  <ng-container *ngIf="!loggedIn; else loggedIn">
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

  constructor(private readonly userService: UserService) {}

  login() {
    this.loggedIn = true;
    this.userService.login('bernhard', 'abc123');
  }

  signup() {
    this.userService.create('bernhard', 'abc123', 'abc123', true);
  }

  logout() {
    this.loggedIn = false;
    this.userService.logout();
  }
}
