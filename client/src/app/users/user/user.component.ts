import { Component, OnInit } from '@angular/core';
import { UsersService } from '../users.service';
import { User } from '../user.model';

@Component({
  selector: 'cube-trainer-user',
  templateUrl: './user.component.html'
})
export class UserComponent implements OnInit {
  user!: User;

  constructor(private readonly usersService: UsersService) {}
    
  ngOnInit() {
    this.updateUser();
  }

  updateUser() {
    this.usersService.show().subscribe(user => {
      this.user = user;
    });
  }
}
