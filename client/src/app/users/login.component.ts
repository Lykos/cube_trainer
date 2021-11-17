import { Component, OnInit } from '@angular/core';
import { UsersService } from './users.service';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { Router } from '@angular/router';

@Component({
  selector: 'cube-trainer-login',
  templateUrl: './login.component.html'
})
export class LoginComponent implements OnInit {
  loginForm!: FormGroup;
  loginFailed = false;

  constructor(private readonly usersService: UsersService,
	      private readonly router: Router,
	      private readonly formBuilder: FormBuilder) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.loginForm = this.formBuilder.group({
      email: ['', Validators.required],
      password: ['', Validators.required],
    });
  }

  onSubmit() {
    this.usersService.login(this.email.value, this.password.value)
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

  get email() { return this.loginForm.get('email')!; }

  get password() { return this.loginForm.get('password')!; }
}
