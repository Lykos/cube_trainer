import { Component, OnInit } from '@angular/core';
import { UsersService } from './users.service';
import { FormGroup, AbstractControl } from '@angular/forms';
import { UserFormCreator } from './user-form-creator.service';
import { NewUser } from './new-user';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';

@Component({
  selector: 'signup',
  template: `
<mat-card>
  <mat-card-title>Sign Up</mat-card-title>
  <form [formGroup]="signupForm" (ngSubmit)="onSubmit()">
    <mat-card-content>
      <mat-form-field appearance="fill">
        <mat-label>Username</mat-label>
        <input type="text" matInput formControlName="name">
        <mat-error *ngIf="relevantInvalid(name) && name.errors.required">
          You must provide a <strong>username</strong>.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(name) && name.errors.uniqueUsernameOrEmail">
          This <strong>username</strong> is already taken.
        </mat-error>
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Email</mat-label>
        <input type="email" matInput formControlName="email">
        <mat-error *ngIf="relevantInvalid(email) && email.errors.required">
          You must provide an <strong>email</strong>.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(email) && email.errors.email">
          You must provide a valid <strong>email</strong>.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(email) && email.errors.uniqueUsernameOrEmail">
          This <strong>email</strong> is already taken.
        </mat-error>
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Password</mat-label>
        <input type="password" matInput formControlName="password">
        <mat-error *ngIf="relevantInvalid(password) && password.errors.required">
          You must provide a <strong>password</strong>.
        </mat-error>
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Confirm Password</mat-label>
        <input type="password" matInput formControlName="passwordConfirmation">
        <mat-error *ngIf="relevantInvalid(passwordConfirmation) && passwordConfirmation.errors.required">
          You must provide a <strong>password confirmation</strong>.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(passwordConfirmation) && passwordConfirmation.errors.compare">
          <strong>Password</strong> must match <strong>password confirmation</strong>.
        </mat-error>
      </mat-form-field>
      <mat-card-actions>
        <button mat-raised-button color="primary" type="submit" [disabled]="!signupForm.valid">
          Submit
        </button>
      </mat-card-actions>
    </mat-card-content>
  </form>
</mat-card>
`
})
export class SignupComponent implements OnInit {
  signupForm!: FormGroup;

  constructor(private readonly usersService: UsersService,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly userFormCreator: UserFormCreator) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.signupForm = this.userFormCreator.createUserForm();
  }

  onSubmit() {
    this.usersService.create(this.newUser).subscribe(r => {
      this.snackBar.open('Signup successful!', 'Close');
      this.router.navigate(['/login']);
    });
  }
    
  get name() { return this.signupForm.get('name')!; }

  get email() { return this.signupForm.get('email')!; }

  get password() { return this.signupForm.get('password')!; }

  get passwordConfirmation() { return this.signupForm.get('passwordConfirmation')!; }

  get newUser(): NewUser {
    return {
      name: this.name.value,
      email: this.email.value,
      password: this.password.value,
      passwordConfirmation: this.passwordConfirmation.value,
    };
  }

  get passwordMismatch() {
    return this.signupForm.errors?.passwordMismatch && (this.passwordConfirmation.touched || this.passwordConfirmation.dirty);
  }
}
