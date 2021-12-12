import { Component, Input } from '@angular/core';
import { HierarchicalAlgSetLevel } from '../hierarchical-alg-set-level.model';

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
  styleUrls: ['./hierarchical-alg-set-select.component.css']
})
export class HierarchicalAlgSetSelectComponent {
  @Input() level: HierarchicalAlgSetLevel;

  get hasSublevels() {
    return this.level.hasSublevels;
  }  
  
  get isExpanded() {
    return this.hasSublevels && this.level.isExpanded;
  }

  get levelName() {
    return this.level.levelName
  }

  get pieceName() {
    return this.level.piece?.name || '';
  }

  get isEnabled() {
    return this.level.isEnabled;
  }

  get hierarchicalExpandOptions() {
    return HIERARCHICAL_EXPAND_OPTIONS;
  }

  get uniformOptions() {
    return this.level.uniformOptions;
  }

  get formGroup() {
    return this.level.formGroup;
  }

  getOrCreateSublevels() {
    return this.level.getOrCreateSublevels();
  }
}
