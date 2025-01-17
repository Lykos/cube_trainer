import { Component, OnInit } from '@angular/core';
import { UsersService } from '../users.service';
import { DumpsService } from '../dumps.service';
import { User } from '../user.model';
import { FileSaverService } from 'ngx-filesaver';
import { MessagesComponent } from '../messages/messages.component';
import { AchievementGrantsComponent } from '../achievement-grants/achievement-grants.component';
import { DeleteAccountButtonComponent } from '../delete-account-button/delete-account-button.component';
import { MatButtonModule } from '@angular/material/button';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'cube-trainer-user',
  templateUrl: './user.component.html',
  imports: [MessagesComponent, AchievementGrantsComponent, DeleteAccountButtonComponent, MatButtonModule, RouterModule],
})
export class UserComponent implements OnInit {
  user!: User;

  constructor(private readonly usersService: UsersService,
              private readonly fileSaverService: FileSaverService,
              private readonly dumpsService: DumpsService) {}
    
  ngOnInit() {
    this.updateUser();
  }

  updateUser() {
    this.usersService.show().subscribe(user => {
      this.user = user;
    });
  }

  download() {
    this.dumpsService.show().subscribe(dump => {
      this.fileSaverService.save(dump, 'user-data.json');
    });
  }
}
