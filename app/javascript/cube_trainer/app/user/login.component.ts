import { Component } from '@angular/core';
import { AuthenticationService } from './authentication.service';

@Component({
  selector: 'login',
  template: `
<mat-card>
  <form (ngSubmit)="onSubmit()">
    <mat-card-title>Login</mat-card-title>
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
      <mat-card-actions>
        <button mat-button type="submit">
          Submit
        </button>
      </mat-card-actions>
    </mat-card-content>
  </form>
</mat-card>
`
})
export class LoginComponent {
  name = '';
  password = '';

  constructor(private readonly authenticationService: AuthenticationService) {}

  onSubmit() {
    this.authenticationService.login(this.name!, this.password!);
  }
}
