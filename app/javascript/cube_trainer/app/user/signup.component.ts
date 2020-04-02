import { Component } from '@angular/core';
import { UserService } from './user.service';

@Component({
  selector: 'signup',
  template: `
<mat-card>
  <mat-card-title>Sign Up</mat-card-title>
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
    <br>
    <mat-form-field appearance="fill">
      <mat-label>Confirm Password</mat-label>
      <input #confirmPassword matInput type="password">
    </mat-form-field>
    <br>
    <mat-checkbox #admin>Admin</mat-checkbox>
    <mat-card-actions>
      <button mat-button (click)="submit(name.value, password.value, confirmPassword.value, admin.value)">
        Submit
      </button>
    </mat-card-actions>
  </mat-card-content>
</mat-card>
`
})
export class SignupComponent {
  constructor(private readonly userService: UserService) {}

  submit(name: string, password: string, confirmPassword: string, admin: boolean) {
    this.userService.create(name, password, confirmPassword, admin);
  }
}
