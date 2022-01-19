import { Component } from '@angular/core';
import { Achievement } from '../achievement.model';
import { ActivatedRoute } from '@angular/router';
import { Observable } from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { orElse } from '@utils/optional';
import { achievementById } from '../achievements.const';

@Component({
  selector: 'cube-trainer-achievement',
  templateUrl: './achievement.component.html'
})
export class AchievementComponent {
  achievementId$: Observable<string>;
  achievement$: Observable<Achievement | undefined>;

  constructor(private readonly activatedRoute: ActivatedRoute) {
    this.achievementId$ = this.activatedRoute.params.pipe(
      map(p => p['achievementId']),
      shareReplay(),
    );
    this.achievement$ = this.achievementId$.pipe(
      map(achievementId => orElse(achievementById(achievementId), undefined)),
    );
  }
}
