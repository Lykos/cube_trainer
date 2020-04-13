import { Component, OnInit } from '@angular/core';
import { UserService } from './user.service';
import { FormBuilder, FormGroup, Validators, AbstractControl, ValidatorFn, ValidationErrors } from '@angular/forms';
import { NewUser } from './new_user';

const passwordMatchValidator: ValidatorFn = (control: AbstractControl): ValidationErrors | null => {
  const password = control.get('password');
  const passwordConfirmation = control.get('passwordConfirmation');

  return password?.value && passwordConfirmation?.value && password.value !== passwordConfirmation.value ? { 'passwordMismatch': true } : null;
}

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
        </mat-form-field>
        <mat-error *ngIf="passwordMismatch">
          <strong>Password</strong> must match <strong>password confirmation</strong>.
        </mat-error>
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

  constructor(private readonly userService: UserService,
	      private readonly formBuilder: FormBuilder) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.signupForm = this.formBuilder.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
      passwordConfirmation: ['', Validators.required],
    }, { validators: passwordMatchValidator });
  }

  onSubmit() {
    this.userService.create(this.newUser).subscribe(r => {});
  }

  get username() { return this.signupForm.get('username')!; }

  get password() { return this.signupForm.get('password')!; }

  get passwordConfirmation() { return this.signupForm.get('passwordConfirmation')!; }

  get newUser(): NewUser {
    return {
      name: this.username.value,
      password: this.password.value,
      passwordConfirmation: this.passwordConfirmation.value,
    };
  }

  get passwordMismatch() {
    return this.signupForm.errors?.passwordMismatch && (this.passwordConfirmation.touched || this.passwordConfirmation.dirty);
  }
}
