import { Component } from '@angular/core';
import { AchievementsService } from '../achievements.service';
import { Observable } from 'rxjs';
import { Achievement } from '../achievement.model';
import { SharedModule } from '@shared/shared.module';

@Component({
  selector: 'cube-trainer-achievements',
  templateUrl: './achievements.component.html',
  styleUrls: ['./achievements.component.css'],
  imports: [SharedModule],
})
export class AchievementsComponent {
  achievements$: Observable<Achievement[]>;
  columnsToDisplay = ['name'];

  constructor(achievementsService: AchievementsService) {
    this.achievements$ = achievementsService.list();
  }

  get context() {
    return {
      action: 'loading',
      subject: 'achievements',
    };
  }
}
