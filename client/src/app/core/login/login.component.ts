import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { Store } from '@ngrx/store';
import { login } from '@store/user.actions';
import { Credentials } from '../credentials.model';

@Component({
  selector: 'cube-trainer-login',
  templateUrl: './login.component.html'
})
export class LoginComponent {
  loginForm: FormGroup;
  loginFailed = false;

  constructor(private readonly formBuilder: FormBuilder,
              private readonly store: Store) {
    this.loginForm = this.formBuilder.group({
      email: ['', Validators.required],
      password: ['', Validators.required],
    });
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
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
