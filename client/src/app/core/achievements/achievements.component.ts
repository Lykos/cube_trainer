import { Component } from '@angular/core';
import { AchievementsService } from '../achievements.service';
import { Observable } from 'rxjs';
import { Achievement } from '../achievement.model';

import { AsyncPipe } from '@angular/common';
import { BackendActionErrorPipe } from '../../shared/backend-action-error.pipe';
import { BackendActionLoadErrorComponent } from '../../shared/backend-action-load-error/backend-action-load-error.component';
import { ErrorPipe } from '../../shared/error.pipe';
import { OrErrorPipe } from '../../shared/or-error.pipe';
import { ValuePipe } from '../../shared/value.pipe';

@Component({
  selector: 'cube-trainer-achievements',
  templateUrl: './achievements.component.html',
  styleUrls: ['./achievements.component.css'],
  imports: [AsyncPipe, BackendActionErrorPipe, BackendActionLoadErrorComponent, ErrorPipe, OrErrorPipe, ValuePipe],
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
