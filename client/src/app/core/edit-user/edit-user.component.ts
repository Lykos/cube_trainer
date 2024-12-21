import { Component, OnInit } from '@angular/core';
import { UsersService } from '../users.service';
import { User } from '../user.model';
import { FormGroup, AbstractControl, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { UserUpdate } from '../user-update.model';
import { UserFormCreator } from '../user-form-creator.service';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';

@Component({
  selector: 'cube-trainer-edit-user',
  templateUrl: './edit-user.component.html',
  styleUrls: ['./edit-user.component.css'],
  imports: [FormsModule, ReactiveFormsModule, MatFormFieldModule, MatButtonModule, MatInputModule],
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
    };
  }

  get nameControl() { return this.editUserForm.get('name')!; }

  get emailControl() { return this.editUserForm.get('email')!; }

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
