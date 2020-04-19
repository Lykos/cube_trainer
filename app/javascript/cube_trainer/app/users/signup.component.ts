import { Component, OnInit } from '@angular/core';
import { UsersService } from './users.service';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { UniqueUsernameOrEmailValidator } from './unique-username-or-email.validator';
import { NewUser } from './new-user';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { RxwebValidators } from "@rxweb/reactive-form-validators";

@Component({
  selector: 'signup',
  template: `
<mat-card>
  <mat-card-title>Sign Up</mat-card-title>
  <form [formGroup]="signupForm" (ngSubmit)="onSubmit()">
    <mat-card-content>
      <mat-form-field appearance="fill">
        <mat-label>Username</mat-label>
        <input type="text" matInput formControlName="username">
        <mat-error *ngIf="relevantInvalid(username) && username.errors.required">
          You must provide a <strong>username</strong>.
        </mat-error>
        <mat-error *ngIf="relevantInvalid(username) && username.errors.uniqueUsernameOrEmail">
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
	      private readonly formBuilder: FormBuilder,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar,
	      private readonly uniqueUsernameOrEmailValidator: UniqueUsernameOrEmailValidator) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.signupForm = this.formBuilder.group({
      username: ['', { validators: Validators.required, asyncValidators: this.uniqueUsernameOrEmailValidator.validate, updateOn: 'blur' }],
      email: ['', { validators: [Validators.email, Validators.required], asyncValidators: this.uniqueUsernameOrEmailValidator.validate, updateOn: 'blur' }],
      password: ['', Validators.required],
      passwordConfirmation: ['', [Validators.required, RxwebValidators.compare({ fieldName: 'password' })]],
    });
  }

  onSubmit() {
    this.usersService.create(this.newUser).subscribe(r => {
      this.snackBar.open('Signup successful!', 'Close');
      this.router.navigate(['/login']);
    });
  }
    
  get username() { return this.signupForm.get('username')!; }

  get email() { return this.signupForm.get('email')!; }

  get password() { return this.signupForm.get('password')!; }

  get passwordConfirmation() { return this.signupForm.get('passwordConfirmation')!; }

  get newUser(): NewUser {
    return {
      name: this.username.value,
      email: this.email.value,
      password: this.password.value,
      passwordConfirmation: this.passwordConfirmation.value,
    };
  }

  get passwordMismatch() {
    return this.signupForm.errors?.passwordMismatch && (this.passwordConfirmation.touched || this.passwordConfirmation.dirty);
  }
}
