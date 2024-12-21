import { Component, Input } from '@angular/core';
import { HierarchicalAlgSetLevel } from '../hierarchical-alg-set-level.model';
import { MatTableModule } from '@angular/material/table';
import { CommonModule } from '@angular/common';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { SharedModule } from '@shared/shared.module';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatCardModule } from '@angular/material/card';

interface TagWithName {
  readonly tag: 'uniform' | 'partial';
  readonly name: string;
}

const HIERARCHICAL_EXPAND_OPTIONS: readonly TagWithName[] = [
  {name: 'same answer for all pieces', tag: 'uniform'},
  {name: 'piece specific answer', tag: 'partial'},
];

@Component({
  selector: 'cube-trainer-hierarchical-alg-set-select',
  templateUrl: './hierarchical-alg-set-select.component.html',
  styleUrls: ['./hierarchical-alg-set-select.component.css'],
  imports: [
    CommonModule,
    SharedModule,
    MatProgressSpinnerModule,
    MatTableModule,
    FormsModule,
    ReactiveFormsModule,
    MatCheckboxModule,
    MatSnackBarModule,
    MatInputModule,
    MatButtonModule,
    MatFormFieldModule,
    MatSelectModule,
    MatCardModule,
  ],
})
export class HierarchicalAlgSetSelectComponent {
  @Input() level: HierarchicalAlgSetLevel | undefined = undefined;

  get hasSublevels() {
    return this.level?.hasSublevels;
  }  
  
  get isExpanded() {
    return this.hasSublevels && this.level?.isExpanded;
  }

  get levelName() {
    return this.level?.levelName
  }

  get pieceName() {
    return this.level?.piece?.name || '';
  }

  get isEnabled() {
    return this.level?.isEnabled;
  }

  get hierarchicalExpandOptions() {
    return HIERARCHICAL_EXPAND_OPTIONS;
  }

  get uniformOptions() {
    return this.level?.uniformOptions;
  }

  get formGroup() {
    // This shall only be called if isEnabled is true and hence the level exists.
    return this.level!.formGroup;
  }

  getOrCreateSublevels() {
    return this.level?.getOrCreateSublevels();
  }
}
