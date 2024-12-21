import { Component } from '@angular/core';
import { AchievementGrantsService } from '../achievement-grants.service';
import { AchievementGrant } from '../achievement-grant.model';
import { Observable } from 'rxjs';

@Component({
  selector: 'cube-trainer-achievement-grants',
  templateUrl: './achievement-grants.component.html',
  styleUrls: ['./achievement-grants.component.css'],
  standalone: false,
})
export class AchievementGrantsComponent {
  achievementGrants$: Observable<AchievementGrant[]>;
  columnsToDisplay = ['achievement', 'timestamp'];

  constructor(private readonly achievementGrantsService: AchievementGrantsService) {
    this.achievementGrants$ = this.achievementGrantsService.list();
  }
}
