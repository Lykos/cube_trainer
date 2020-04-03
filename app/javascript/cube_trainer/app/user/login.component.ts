import { Component } from '@angular/core';
import { UserService } from './user.service';

@Component({
  selector: 'login',
  template: `
<mat-card>
  <mat-card-title>Login</mat-card-title>
  <mat-card-content>
    <mat-form-field appearance="fill">
      <mat-label>Name</mat-label>
      <input #name matInput type="text">
    </mat-form-field>
    <br>
    <mat-form-field appearance="fill">
      <mat-label>Password</mat-label>
      <input #password matInput type="password">
    </mat-form-field>
    <mat-card-actions>
      <button mat-button (click)="submit(name.value, password.value)">
        Submit
      </button>
    </mat-card-actions>
  </mat-card-content>
</mat-card>
`
})
export class LoginComponent {
  constructor(private readonly userService: UserService) {}

  submit(name: string, password: string) {
    this.userService.login(name, password);
  }
}
