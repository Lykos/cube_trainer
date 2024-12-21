import { Component, Input } from '@angular/core';
import { StatPart, CountStatPart, FractionStatPart, DnfStatPart, UndefinedStatPart, DurationStatPart, isCountStatPart, isFractionStatPart, isDnfStatPart, isUndefinedStatPart, isDurationStatPart } from '../stat-part.model';

@Component({
  selector: 'cube-trainer-stat-part-value',
  templateUrl: './stat-part-value.component.html',
  styleUrls: ['./stat-part-value.component.css'],
  standalone: false,
})
export class StatPartValueComponent {
  @Input()
  statPart?: StatPart;

  get countStatPart(): CountStatPart | undefined {
    return this.statPart && isCountStatPart(this.statPart) ? this.statPart : undefined
  }

  get fractionStatPart(): FractionStatPart | undefined {
    return this.statPart && isFractionStatPart(this.statPart) ? this.statPart : undefined
  }

  get durationStatPart(): DurationStatPart | undefined {
    return this.statPart && isDurationStatPart(this.statPart) ? this.statPart : undefined
  }

  get dnfStatPart(): DnfStatPart | undefined {
    return this.statPart && isDnfStatPart(this.statPart) ? this.statPart : undefined
  }

  get undefinedStatPart(): UndefinedStatPart | undefined {
    return this.statPart && isUndefinedStatPart(this.statPart) ? this.statPart : undefined
  }
}
