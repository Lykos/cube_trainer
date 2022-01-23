import { statTypes } from '../stat-types.const';
import { TrainingSessionType } from '../training-session-type.model';
import { StatType } from '../stat-type.model';
import { Component, Input, Output, EventEmitter, OnInit } from '@angular/core';
import { CdkDragDrop, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';

@Component({
  selector: 'cube-trainer-select-stats',
  templateUrl: './select-stats.component.html',
  styleUrls: ['./select-stats.component.css']
})
export class SelectStatsComponent implements OnInit {
  @Input()
  trainingSessionType?: TrainingSessionType;

  pickedStatTypes: StatType[] = [];

  @Output()
  pickedStatTypesChanged = new EventEmitter<StatType[]>();

  lastTrainingSessionTypeForStatsTypes: TrainingSessionType | undefined
  statTypesForLastTrainingSessionType: StatType[] = [];

  ngOnInit() {
    this.pickedStatTypesChanged.emit(this.pickedStatTypes);
  }

  get statTypesForCurrentTrainingSessionType() {
    if (this.lastTrainingSessionTypeForStatsTypes !== this.trainingSessionType) {
      this.statTypesForLastTrainingSessionType = statTypes.filter(s => !s.needsBoundedInputs || this.trainingSessionType!.hasBoundedInputs);
      this.lastTrainingSessionTypeForStatsTypes = this.trainingSessionType;
    }
    return this.statTypesForLastTrainingSessionType;
  }

  drop(event: CdkDragDrop<StatType[]>) {
    if (event.previousContainer === event.container) {
      moveItemInArray(event.container.data, event.previousIndex, event.currentIndex);
      this.pickedStatTypesChanged.emit(this.pickedStatTypes);
    } else {
      transferArrayItem(event.previousContainer.data,
                        event.container.data,
                        event.previousIndex,
                        event.currentIndex);
      this.pickedStatTypesChanged.emit(this.pickedStatTypes);
    }
  }
}
