import { Component, OnInit } from '@angular/core';
import { AuthenticationService } from './authentication.service';

@Component({
  selector: 'cube-trainer-logout',
  templateUrl: './logout.component.html',
})
export class LogoutComponent implements OnInit {
  constructor(private readonly authenticationService: AuthenticationService) {}  

  onDeleteAccount() {
    this.authenticationService.logout();
  }
}
