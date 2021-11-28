import { Injectable } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { RxwebValidators } from "@rxweb/reactive-form-validators";
import { UniqueUsernameOrEmailValidator } from './unique-username-or-email.validator';
import { User } from './user.model';

@Injectable({
  providedIn: 'root',
})
export class UserFormCreator {
  constructor(private readonly formBuilder: FormBuilder,
	      private readonly uniqueUsernameOrEmailValidator: UniqueUsernameOrEmailValidator) {}
  createSignupForm(): FormGroup {
    return this.formBuilder.group({
      name: [
	'',
	{
	  validators: Validators.required,
	  asyncValidators: this.uniqueUsernameOrEmailValidator.validate(),
	  updateOn: 'blur',
	}
      ],
      email: [
	'', {
	  validators: [
	    Validators.email,
	    Validators.required
	  ],
	  asyncValidators: this.uniqueUsernameOrEmailValidator.validate(),
	  updateOn: 'blur'
	}
      ],
      password: [
	'',
	[Validators.required],
      ],
      passwordConfirmation: [
	'',
	[Validators.required, RxwebValidators.compare({ conditionalExpression: (x: any) => x.password || x.passwordConfirmation, fieldName: 'password' })],
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
	[Validators.required],
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
	  asyncValidators: this.uniqueUsernameOrEmailValidator.validate(user?.name),
	  updateOn: 'blur',
	}
      ],
      email: [
	user.email, {
	  validators: [
	    Validators.email,
	    Validators.required
	  ],
	  asyncValidators: this.uniqueUsernameOrEmailValidator.validate(user?.email),
	  updateOn: 'blur'
	}
      ],
      password: [
	'',
	[]
      ],
      passwordConfirmation: [
	'',
	[RxwebValidators.compare({ conditionalExpression: (x: any) => x.password || x.passwordConfirmation, fieldName: 'password' })],
      ],
    });
  }
}
