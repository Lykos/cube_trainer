import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { Store } from '@ngrx/store';
import { login } from '../../state/user.actions';
import { Credentials } from '../credentials.model';

@Component({
  selector: 'cube-trainer-login',
  templateUrl: './login.component.html'
})
export class LoginComponent implements OnInit {
  loginForm!: FormGroup;
  loginFailed = false;

  constructor(private readonly formBuilder: FormBuilder,
              private readonly  store: Store) {}

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
    this.store.dispatch(login({ credentials: this.credentials }));
  }

  get credentials(): Credentials {
    return { email: this.email.value, password: this.password.value };
  }

  get email() { return this.loginForm.get('email')!; }

  get password() { return this.loginForm.get('password')!; }
}
