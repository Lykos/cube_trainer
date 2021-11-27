import { Component, OnInit } from '@angular/core';
import { AchievementGrantsService } from '../achievement-grants.service';
import { AchievementGrant } from '../achievement-grant.model';
import { Observable } from 'rxjs';

@Component({
  selector: 'cube-trainer-achievement-grants',
  templateUrl: './achievement-grants.component.html',
  styleUrls: ['./achievement-grants.component.css']
})
export class AchievementGrantsComponent implements OnInit {
  userId$: Observable<number>;
  achievementGrants: AchievementGrant[] = [];
  columnsToDisplay = ['achievement', 'timestamp'];

  constructor(private readonly achievementGrantsService: AchievementGrantsService) {}

  ngOnInit() {
    this.achievementGrantsService.list()
      .subscribe((achievementGrants: AchievementGrant[]) => {
	this.achievementGrants = achievementGrants
      });
  }
}
