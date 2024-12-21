import { Component } from '@angular/core';
import { AchievementGrantsService } from '../achievement-grants.service';
import { AchievementGrant } from '../achievement-grant.model';
import { Observable } from 'rxjs';
import { AsyncPipe } from '@angular/common';
import { MatTableModule } from '@angular/material/table';
import { InstantPipe } from '../../shared/instant.pipe';
import { OrErrorPipe } from '../../shared/or-error.pipe';
import { ValuePipe } from '../../shared/value.pipe';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'cube-trainer-achievement-grants',
  templateUrl: './achievement-grants.component.html',
  styleUrls: ['./achievement-grants.component.css'],
  imports: [
    AsyncPipe,
    InstantPipe,
    OrErrorPipe,
    ValuePipe,
    MatProgressSpinnerModule,
    MatTooltipModule,
    RouterLink,
    MatTableModule,
  ],
})
export class AchievementGrantsComponent {
  achievementGrants$: Observable<AchievementGrant[]>;
  columnsToDisplay = ['achievement', 'timestamp'];

  constructor(private readonly achievementGrantsService: AchievementGrantsService) {
    this.achievementGrants$ = this.achievementGrantsService.list();
  }
}
