import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { Store } from '@ngrx/store';
import { login } from '@store/user.actions';
import { Credentials } from '../credentials.model';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'cube-trainer-login',
  templateUrl: './login.component.html',
  imports: [FormsModule, ReactiveFormsModule, MatFormFieldModule, MatCardModule, MatButtonModule],
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
