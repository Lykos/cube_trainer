import { Component, OnInit } from '@angular/core';
import { AuthenticationService } from './authentication.service';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { Router } from '@angular/router';

@Component({
  selector: 'cube-trainer-login',
  templateUrl: './login.component.html'
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
