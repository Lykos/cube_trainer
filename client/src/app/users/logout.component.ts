import { Component, OnInit } from '@angular/core';
import { UsersService } from './users.service';

@Component({
  selector: 'cube-trainer-logout',
  templateUrl: './logout.component.html',
})
export class LogoutComponent implements OnInit {
  constructor(private readonly usersService: UsersService) {}  

  ngOnInit() {
    this.usersService.logout();
  }
}
