import { Component, OnInit } from '@angular/core';
import { DeleteAccountConfirmationDialogComponent } from '../delete-account-confirmation-dialog/delete-account-confirmation-dialog.component';
import { AuthenticationService } from '../authentication.service';
import { UsersService } from '../users.service';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { MatSnackBar } from '@angular/material/snack-bar';
import { User } from '../user.model';
import { Optional, ifPresent } from '../../utils/optional';

@Component({
  selector: 'cube-trainer-delete-account-button',
  templateUrl: './delete-account-button.component.html',
})
export class DeleteAccountButtonComponent implements OnInit {
  user!: Optional<User>;

  constructor(private readonly usersService: UsersService,
	      private readonly dialog: MatDialog,
	      private readonly snackBar: MatSnackBar,
              private readonly router: Router,
              private readonly authenticationService: AuthenticationService) {}  

  ngOnInit() {
    this.authenticationService.currentUser$.subscribe(
      (user) => {
	this.user = user;
      });
  }

  onDeleteAccount() {
    ifPresent(this.user, user => {
      const dialogRef = this.dialog.open(DeleteAccountConfirmationDialogComponent, { data: user });

      dialogRef.afterClosed().subscribe(r => {
        if (r) {
          this.reallyDeleteAccount(user);
        }
      });
    });
  }

  private reallyDeleteAccount(user: User) {
    this.usersService.destroy(user.id).subscribe(r => {
      this.snackBar.open(`User ${user.name} with all its data deleted`, 'Close');
      this.authenticationService.logout();
      this.router.navigate(['account_deleted']);
    });
  }
}
