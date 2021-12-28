import { Component } from '@angular/core';
import { AchievementsService } from '../achievements.service';
import { Observable } from 'rxjs';
import { Achievement } from '../achievement.model';

@Component({
  selector: 'cube-trainer-achievements',
  templateUrl: './achievements.component.html',
  styleUrls: ['./achievements.component.css']
})
export class AchievementsComponent {
  achievements$: Observable<Achievement[]>;
  columnsToDisplay = ['name'];

  constructor(achievementsService: AchievementsService) {
    this.achievements$ = achievementsService.list();
  }

  routerLink(achievement: Achievement) {
    return `/achievements/${achievement.key}`;
  }

  get context() {
    return {
      action: 'loading',
      subject: 'achievements',
    };
  }
}
