import { Injectable } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { RxwebValidators } from "@rxweb/reactive-form-validators";
import { User } from './user.model';

@Injectable({
  providedIn: 'root',
})
export class UserFormCreator {
  constructor(private readonly formBuilder: FormBuilder) {}

  createSignupForm(): FormGroup {
    return this.formBuilder.group({
      name: [
	'',
	{
	  validators: Validators.required,
	  updateOn: 'blur',
	}
      ],
      email: [
	'', {
	  validators: [
	    Validators.email,
	    Validators.required
	  ],
	  updateOn: 'blur'
	}
      ],
      password: [
	'',
	[Validators.required, Validators.minLength(6)],
      ],
      passwordConfirmation: [
	'',
	[
          Validators.required,
          RxwebValidators.compare({ conditionalExpression: (x: any) => x.password || x.passwordConfirmation, fieldName: 'password' }),
        ],
      ],
      termsAndConditionsAccepted: [false, Validators.requiredTrue],
      privacyPolicyAccepted: [false, Validators.requiredTrue],
      cookiePolicyAccepted: [false, Validators.requiredTrue],
    });
  }

  createUpdatePasswordForm(): FormGroup {
    return this.formBuilder.group({
      password: [
	'',
	[Validators.required, Validators.minLength(6)],
      ],
      passwordConfirmation: [
	'',
	([Validators.required]).concat([RxwebValidators.compare({ conditionalExpression: (x: any) => x.password || x.passwordConfirmation, fieldName: 'password' })]),
      ],
    });
  }

  createChangePasswordForm(): FormGroup {
    return this.formBuilder.group({
      currentPassword: [
	'',
	[Validators.required],
      ],
      password: [
	'',
	[Validators.required, Validators.minLength(6)],
      ],
      passwordConfirmation: [
	'',
	([Validators.required]).concat([RxwebValidators.compare({ conditionalExpression: (x: any) => x.password || x.passwordConfirmation, fieldName: 'password' })]),
      ],
    });
  }

  createUpdateUserForm(user: User): FormGroup {
    return this.formBuilder.group({
      name: [
	user.name,
	{
	  validators: Validators.required,
	  updateOn: 'blur',
	}
      ],
      email: [
	user.email, {
	  validators: [
	    Validators.email,
	    Validators.required
	  ],
	  updateOn: 'blur'
	}
      ],
    });
  }
}
