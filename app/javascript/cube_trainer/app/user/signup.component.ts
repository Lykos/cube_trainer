import { Component } from '@angular/core';
import { UserService } from './user.service';
import { User } from './user';

@Component({
  selector: 'signup',
  template: `
<mat-card>
  <form (ngSubmit)="onSubmit()">
    <mat-card-title>Sign Up</mat-card-title>
    <mat-card-content>
      <mat-form-field appearance="fill">
        <mat-label>Name</mat-label>
        <input required [(ngModel)]="user.name" name="name" matInput type="text">
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Password</mat-label>
        <input required [(ngModel)]="user.password" name="password" matInput type="password">
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Confirm Password</mat-label>
        <input required [(ngModel)]="user.confirmPassword" name="confirmPassword" matInput type="password">
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
export class SignupComponent {
  readonly newUser: NewUser = {
    name = '';
    password = '';
    confirmPassword = '';
    admin = false;
  };

  constructor(private readonly userService: UserService) {}

  onSubmit() {
    this.userService.create(this.newUser).subscribe(r => {});
  }
}
