import { Component } from '@angular/core';
import { FormGroup, AbstractControl } from '@angular/forms';
import { ModeType } from '../mode-type.model';
import { ModesService } from '../modes.service';
import { ModeFormsService } from '../mode-forms.service';
import { NewMode } from '../new-mode.model';
import { AlgSet } from '../alg-set.model';
import { StatType } from '../stat-type.model';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
import { CdkDragDrop, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';

@Component({
  selector: 'cube-trainer-new-mode',
  templateUrl: './new-mode.component.html',
  styleUrls: ['./new-mode.component.css']
})
export class NewModeComponent {
  modeTypeGroup: FormGroup;
  algSetGroup: FormGroup;
  setupGroup: FormGroup;
  trainingGroup: FormGroup;
  modeTypes$: Observable<ModeType[]>;
  pickedStatTypes: StatType[] = [];

  lastModeTypeForStatsTypes: ModeType | undefined
  statTypesForLastModeType: StatType[] = [];
  
  constructor(private readonly modeFormsService: ModeFormsService,
	      private readonly modesService: ModesService,
	      private readonly router: Router,
	      private readonly snackBar: MatSnackBar) {
    this.modeTypes$ = this.modesService.listTypes();
    this.modeTypeGroup = this.modeFormsService.modeTypeGroup();
    this.algSetGroup = this.modeFormsService.algSetGroup(() => this.modeType);
    this.setupGroup = this.modeFormsService.setupGroup(() => this.modeType);
    this.trainingGroup = this.modeFormsService.trainingGroup(() => this.modeType);
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  get name() {
    return this.modeTypeGroup.get('name')!;
  }

  get statTypesForCurrentModeType() {
    if (this.lastModeTypeForStatsTypes !== this.modeType) {
      this.statTypesForLastModeType = Object.assign([], this.modeType!.statsTypes);
      this.lastModeTypeForStatsTypes = this.modeType;
    }
    return this.statTypesForLastModeType;
  }

  get hasMultipleShowInputModes() {
    return this.modeType && this.modeType.showInputModes.length > 1;
  }

  get cubeSize() {
    return this.setupGroup.get('cubeSize')!;
  }

  get buffer() {
    return this.setupGroup.get('buffer')!;
  }

  get goalBadness() {
    return this.trainingGroup.get('goalBadness')!;
  }

  get memoTimeS() {
    return this.trainingGroup.get('memoTimeS')!;
  }

  get showInputMode() {
    return this.trainingGroup.get('showInputMode')!;
  }

  get defaultCubeSize() {
    return this.modeType?.cubeSizeSpec?.default;
  }

  get minCubeSize() {
    return this.modeType?.cubeSizeSpec?.min;
  }

  get maxCubeSize() {
    return this.modeType?.cubeSizeSpec?.max;
  }

  get modeTypeControl(): AbstractControl {
    return this.modeTypeGroup.get('modeType')!;
  }

  get modeType(): ModeType | undefined {
    return this.modeTypeControl.value;
  }

  get algSetControl(): AbstractControl {
    return this.algSetGroup.get('algSet')!;
  }

  get algSet(): AlgSet | undefined {
    return this.algSetControl.value;
  }

  get selectedShowInputMode() {
    if (this.modeType && this.modeType.showInputModes.length == 1) {
      return this.modeType.showInputModes[0];
    } else if (this.hasMultipleShowInputModes) {
      return this.showInputMode.value;
    } else {
      return undefined;
    }
  }

  get hasMultipleCubeSizes(): boolean {
    const cubeSizeSpec = this.modeType?.cubeSizeSpec;
    return !!cubeSizeSpec && cubeSizeSpec.min < cubeSizeSpec.max;
  }

  get selectedCubeSize(): number | undefined {
    if (this.hasMultipleCubeSizes) {
      return this.cubeSize.value;
    } else {
      return this.defaultCubeSize;
    }
  }

  get bufferAlgSets(): AlgSet[] {
    const modeType = this.modeType;
    if (!modeType || !modeType?.buffers?.length) {
      return [];
    }
    const buffer = this.buffer.value;
    if (!buffer) {
      return [];
    }
    return modeType.algSets.filter(a => a.buffer.key === buffer.key);
  }

  get newMode(): NewMode {
    return {
      modeType: this.modeType!,
      name: this.name.value,
      known: !!this.trainingGroup.get('known')?.value,
      showInputMode: this.selectedShowInputMode,
      buffer: this.buffer.value,
      goalBadness: this.goalBadness.value,
      memoTimeS: this.memoTimeS.value,
      cubeSize: this.selectedCubeSize,
      statTypes: this.pickedStatTypes.map(s => s.key),
      algSet: this.algSet,
    };
  }

  onSubmit() {
    console.log(`Creating ${JSON.stringify(this.newMode)}`);
    this.modesService.create(this.newMode).subscribe(
      r => {
	this.snackBar.open(`Mode ${this.newMode.name} Created!`, 'Close');
	this.router.navigate([`/modes`]);
      });
  }

  drop(event: CdkDragDrop<StatType[]>) {
    if (event.previousContainer === event.container) {
      moveItemInArray(event.container.data, event.previousIndex, event.currentIndex);
    } else {
      transferArrayItem(event.previousContainer.data,
                        event.container.data,
                        event.previousIndex,
                        event.currentIndex);
    }
  }
}
