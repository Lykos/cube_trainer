import { MatSnackBar } from '@angular/material/snack-bar';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, AbstractControl, Validators } from '@angular/forms';
import { RxwebValidators } from "@rxweb/reactive-form-validators";
import { UsersService } from '../users.service';
import { PasswordUpdate } from '../password-update.model';

@Component({
  selector: 'cube-trainer-update-password',
  templateUrl: './update-password.component.html',
  styleUrls: ['./update-password.component.css']
})
export class UpdatePasswordComponent implements OnInit {
  form!: FormGroup;

  constructor(private readonly formBuilder: FormBuilder,
	      private readonly snackBar: MatSnackBar,
              private readonly usersService: UsersService) {}

  get passwordControl() { return this.form.get('password')!; }

  get passwordConfirmationControl() { return this.form.get('passwordConfirmation')!; }

  get passwordUpdate(): PasswordUpdate {
    return {
      password: this.passwordControl.value,
      passwordConfirmation: this.passwordConfirmationControl.value
    };
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  onSubmit() {
    this.usersService.updatePassword(this.passwordUpdate).subscribe(r => {
      this.snackBar.open('Password updated!', 'Close');
    });
  }
    
  ngOnInit() {
    this.form = this.formBuilder.group({
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
}
