import { Component } from '@angular/core';
import { AchievementsService } from '../achievements.service';
import { Achievement } from '../achievement.model';
import { ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { map, switchMap } from 'rxjs/operators';

import { AsyncPipe } from '@angular/common';
import { OrErrorPipe } from '../../shared/or-error.pipe';
import { ValuePipe } from '../../shared/value.pipe';

@Component({
  selector: 'cube-trainer-achievement',
  templateUrl: './achievement.component.html',
  imports: [AsyncPipe, OrErrorPipe, ValuePipe],
})
export class AchievementComponent {
  achievement$: Observable<Achievement>;

  constructor(private readonly achievementsService: AchievementsService,
	      private readonly activatedRoute: ActivatedRoute) {
    this.achievement$ = this.activatedRoute.params.pipe(
      map(p => p['achievementId']),
      switchMap(achievementId => this.achievementsService.show(achievementId)),
    );
  }
}
