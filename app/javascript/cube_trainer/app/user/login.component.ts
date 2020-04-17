import { Component, OnInit } from '@angular/core';
import { AuthenticationService } from './authentication.service';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { Router } from '@angular/router';

@Component({
  selector: 'login',
  template: `
<mat-card>
  <mat-card-title>Login</mat-card-title>
  <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
    <mat-card-content>
      <mat-form-field appearance="fill">
        <mat-label>Username or Email</mat-label>
        <input matInput type="text" formControlName="usernameOrEmail">
        <mat-error *ngIf="relevantInvalid(usernameOrEmail) && usernameOrEmail.errors.required">
          You must provide a <strong>username</strong> or <strong>email</strong>.
        </mat-error>
      </mat-form-field>
      <br>
      <mat-form-field appearance="fill">
        <mat-label>Password</mat-label>
        <input matInput type="password" formControlName="password">
        <mat-error *ngIf="relevantInvalid(password) && password.errors.required">
          You must provide a <strong>password</strong>.
        </mat-error>
      </mat-form-field>
      <br>
      <mat-error *ngIf="loginFailed">
        User name or password incorrect.
      </mat-error>
    </mat-card-content>
    <mat-card-actions>
      <button mat-raised-button color="primary" [disabled]="!loginForm.valid">
        Submit
      </button>
    </mat-card-actions>
  </form>
</mat-card>
`
})
export class LoginComponent implements OnInit {
  loginForm!: FormGroup;
  loginFailed = false;

  constructor(private readonly authenticationService: AuthenticationService,
	      private readonly router: Router,
	      private readonly formBuilder: FormBuilder) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.loginForm = this.formBuilder.group({
      usernameOrEmail: ['', Validators.required],
      password: ['', Validators.required],
    });
  }

  onSubmit() {
    this.authenticationService.login(this.usernameOrEmail.value, this.password.value)
      .subscribe(
	r => {
	  this.router.navigate(['/modes']);
	},
	err => {
	  if (err.status == 401) {
	    this.loginFailed = true;
	  }
	},
      );
  }

  get usernameOrEmail() { return this.loginForm.get('usernameOrEmail')!; }

  get password() { return this.loginForm.get('password')!; }
}
