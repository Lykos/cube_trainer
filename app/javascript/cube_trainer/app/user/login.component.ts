import { Component } from '@angular/core';
import { AuthenticationService } from './authentication.service';

@Component({
  selector: 'login',
  template: `
<mat-card>
  <mat-card-title>Login</mat-card-title>
  <form (ngSubmit)="onSubmit()">
    <mat-card-content>
      <mat-form-field appearance="fill">
        <mat-label>Name</mat-label>
        <input required [(ngModel)]="name" name="name" matInput type="text">
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Password</mat-label>
        <input required [(ngModel)]="password" name="password" matInput type="password">
      </mat-form-field>
      <mat-label color='warn' *ngIf="loginFailed">
        User name or password incorrect.
      </mat-label>
    </mat-card-content>
    <mat-card-actions>
      <button mat-button type="submit">
        Submit
      </button>
    </mat-card-actions>
  </form>
</mat-card>
`
})
export class LoginComponent {
  name = '';
  password = '';
  loginFailed = false;

  constructor(private readonly authenticationService: AuthenticationService) {}

  onSubmit() {
    this.authenticationService.login(this.name, this.password).subscribe(
      r => { this.loginFailed = false; }
      err => { this.loginFailed = true; }
    );
  }
}
