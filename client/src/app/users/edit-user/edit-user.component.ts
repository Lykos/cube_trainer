import { Component, OnInit } from '@angular/core';
import { UsersService } from '../users.service';
import { User } from '../user.model';
import { FormGroup, AbstractControl } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { UserUpdate } from '../user-update.model';
import { UserFormCreator } from '../user-form-creator.service';

@Component({
  selector: 'cube-trainer-edit-user',
  templateUrl: './edit-user.component.html',
  styleUrls: ['./edit-user.component.css']
})
export class EditUserComponent implements OnInit {
  user!: User;
  editUserForm!: FormGroup;

  constructor(private readonly usersService: UsersService,
	      private readonly userFormCreator: UserFormCreator,
	      private readonly snackBar: MatSnackBar) {}

  get userUpdate(): UserUpdate {
    return {
      name: this.nameControl.value,
      email: this.emailControl.value,
      password: this.passwordControl.value,
      passwordConfirmation: this.passwordConfirmationControl.value
    };
  }

  get nameControl() { return this.editUserForm.get('name')!; }

  get emailControl() { return this.editUserForm.get('email')!; }

  get passwordControl() { return this.editUserForm.get('password')!; }

  get passwordConfirmationControl() { return this.editUserForm.get('passwordConfirmation')!; }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  onSubmit() {
    this.usersService.update(this.userUpdate).subscribe(r => {
      this.updateUser();
      this.snackBar.open('Update successful!', 'Close');
    });
  }
    
  ngOnInit() {
    this.usersService.show().subscribe(user => {
      this.user = user;
      // TODO: The form should be created before the user exists, prefilling can happen later.
      this.editUserForm = this.userFormCreator.createUpdateUserForm(user);
    });
  }

  updateUser() {
    this.usersService.show().subscribe(user => {
      this.user = user;
    });
  }
}
