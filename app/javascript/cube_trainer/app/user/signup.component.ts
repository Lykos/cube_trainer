import { Component } from '@angular/core';
import { UserService } from './user.service';
import { NewUser } from './new_user';

@Component({
  selector: 'signup',
  template: `
<mat-card>
  <mat-card-title>Sign Up</mat-card-title>
  <form (ngSubmit)="onSubmit()">
    <mat-card-content>
      <mat-form-field appearance="fill">
        <mat-label>Name</mat-label>
        <input required [(ngModel)]="newUser.name" name="name" matInput type="text">
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Password</mat-label>
        <input required [(ngModel)]="newUser.password" name="password" matInput type="password">
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Confirm Password</mat-label>
        <input required [(ngModel)]="newUser.passwordConfirmation" name="passwordConfirmation" matInput type="password">
      </mat-form-field>
      <mat-card-actions>
        <button mat-button color="primary" type="submit">
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
    name: '',
    password: '',
    passwordConfirmation: '',
    admin: false,
  };

  constructor(private readonly userService: UserService) {}

  onSubmit() {
    this.userService.create(this.newUser).subscribe(r => {});
  }
}
