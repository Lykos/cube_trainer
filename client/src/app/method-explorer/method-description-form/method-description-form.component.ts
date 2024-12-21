import { Piece } from '@utils/cube-stats/piece';
import { PieceWithName, piecesWithNames } from '../piece-with-name.model';
import { ModeWithName, HierarchicalAlgSetLevel } from '../hierarchical-alg-set-level.model';
import { find } from '@utils/utils';
import { Optional, hasValue, forceValue, some, none } from '@utils/optional';
import { assert } from '@utils/assert';
import { ExecutionOrder, PieceMethodDescription, MethodDescription, BufferDescription, UniformAlgSetMode, HierarchicalAlgSet } from '@utils/cube-stats/method-description';
import { CORNER, EDGE, PieceDescription } from '@utils/cube-stats/piece-description';
import { Component, Output, EventEmitter } from '@angular/core';
import { FormBuilder, FormGroup, FormArray } from '@angular/forms';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
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
import { HierarchicalAlgSetSelectComponent } from '../hierarchical-alg-set-select/hierarchical-alg-set-select.component';

const UNIFORM_OPTIONS: readonly ModeWithName[] = [
  {name: 'I know all algs from this set', mode: UniformAlgSetMode.ALL},
  {name: 'I know all oriented algs from this set', mode: UniformAlgSetMode.ONLY_ORIENTED},
  {name: 'I know no algs from this set', mode: UniformAlgSetMode.NONE},
];

const UNIFORM_OPTIONS_WITHOUT_ORIENTED: readonly ModeWithName[] = UNIFORM_OPTIONS.filter(o => o.mode !== UniformAlgSetMode.ONLY_ORIENTED);

interface AlgSetLevelHelper {
  name: string;
  isEnabledPiece(piece: PieceWithName | undefined): boolean;
}

class HierarchicalAlgSetLevelImpl implements HierarchicalAlgSetLevel {
  readonly formGroup: FormGroup;
  private sublevels: Optional<readonly HierarchicalAlgSetLevel[]> = none;

  constructor(private readonly formBuilder: FormBuilder,
              readonly uniformOptions: readonly ModeWithName[],
              private readonly helpers: readonly AlgSetLevelHelper[],
              private readonly pieces: readonly PieceWithName[],
              private readonly piecePath: readonly PieceWithName[]) {
    assert(this.helpers.length > 0);
    this.formGroup =  this.formBuilder.group({
      tag: ['uniform'],
      mode: [UniformAlgSetMode.NONE],
      subsets: this.formBuilder.array([]),
    });
  }

  get levelName(): string {
    return this.helpers[0].name;
  }

  get piece(): PieceWithName | undefined {
    return this.piecePath.length > 0 ? this.piecePath[this.piecePath.length - 1] : undefined;
  }

  get value(): HierarchicalAlgSet<any> {
    return this.formGroup.value;
  }

  get isExpanded(): boolean {
    return this.value.tag === 'partial';
  }

  get isEnabled(): boolean {
    return this.helpers[0].isEnabledPiece(this.piece) ;
  }

  get hasSublevels(): boolean {
    return this.helpers.length > 1;
  }

  get unusedPieces(): PieceWithName[] {
    return this.pieces.filter(piece => !this.piecePath.some(p => p.piece.pieceId === piece.piece.pieceId))    
  }

  getOrCreateSublevels(): readonly HierarchicalAlgSetLevel[] {
    if (!this.hasSublevels) {
      return [];
    }
    if (hasValue(this.sublevels)) {
      return forceValue(this.sublevels);
    }
    const sublevels: HierarchicalAlgSetLevel[] = [];
    const subsets = this.formGroup.get('subsets')! as FormArray;
    for (let piece of this.unusedPieces) {
      const sublevel = new HierarchicalAlgSetLevelImpl(this.formBuilder, this.uniformOptions, this.helpers.slice(1), this.pieces, this.piecePath.concat([piece]));
      sublevels.push(sublevel);
      subsets.push(this.formBuilder.group({piece: piece.piece, subset: sublevel.formGroup}));
    }
    this.sublevels = some(sublevels);
    return sublevels;
  }
}

@Component({
  selector: 'cube-trainer-method-description-form',
  templateUrl: './method-description-form.component.html',
  styleUrls: ['./method-description-form.component.css'],
  imports: [
    CommonModule,
    SharedModule,
    MatProgressSpinnerModule,
    BrowserModule,
    BrowserAnimationsModule,
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
    HierarchicalAlgSetSelectComponent,
  ],
})
export class MethodDescriptionFormComponent {
  piecesEqual(left: Piece, right: Piece) {
    return left.pieceId === right.pieceId;
  }

  @Output()
  private submitMethodDescription: EventEmitter<MethodDescription> = new EventEmitter();

  readonly form: FormGroup;
  readonly doubleSwapsTopLevelByPieceDescription: readonly [PieceDescription, HierarchicalAlgSetLevel][];
  
  constructor(private readonly formBuilder: FormBuilder) {
    this.doubleSwapsTopLevelByPieceDescription = this.pieceDescriptions.map(p => [p, this.createDoubleSwapsTopLevel(p)]);
    this.form = this.formBuilder.group({
      executionOrder: [ExecutionOrder.EC],
      pieceMethodDescriptions: this.formBuilder.array(this.pieceDescriptions.map(p => {
        return this.formBuilder.group({
          pluralName: [p.pluralName],
          maxFloatingTwistLength: [0],
          sortedBufferDescriptions: this.formBuilder.array([this.createBufferGroup(p.pieces[0])]),
          avoidUnorientedIfWeCanFloat: [false],
          avoidBuffersForCycleBreaks: [false],
          doubleSwaps: this.doubleSwapsTopLevel(p).formGroup,
        });
      })),
    });
  }

  private doubleSwapLevelHelpers(pieceDescription: PieceDescription): readonly AlgSetLevelHelper[] {
    return [
      { name: 'Double Swaps for Buffer Switches', isEnabledPiece: () => this.canFloat(pieceDescription) },
      { name: 'first buffer', isEnabledPiece: (p: PieceWithName) => this.buffers(pieceDescription).some(b => b.pieceId === p.piece.pieceId) },
      { name: 'second buffer', isEnabledPiece: (p: PieceWithName) => this.buffers(pieceDescription).some(b => b.pieceId === p.piece.pieceId) },
      { name: 'third piece', isEnabledPiece: () => true },
      { name: 'fourth piece', isEnabledPiece: () => true },
    ];
  }

  private createDoubleSwapsTopLevel(pieceDescription: PieceDescription): HierarchicalAlgSetLevel {
    return new HierarchicalAlgSetLevelImpl(
      this.formBuilder, this.uniformOptions(pieceDescription),
      this.doubleSwapLevelHelpers(pieceDescription),
      this.piecesWithNames(pieceDescription), []);
  }

  doubleSwapsTopLevel(pieceDescription: PieceDescription): HierarchicalAlgSetLevel {
    return forceValue(find(this.doubleSwapsTopLevelByPieceDescription, e => e[0].pluralName === pieceDescription.pluralName))[1];
  }

  private uniformOptions(pieceDescription: PieceDescription) {
    return pieceDescription.hasOrientation ? UNIFORM_OPTIONS : UNIFORM_OPTIONS_WITHOUT_ORIENTED;
  }

  piecesWithNames(pieceDescription: PieceDescription): readonly PieceWithName[] {
    return piecesWithNames(pieceDescription);
  }

  buffers(pieceDescription: PieceDescription) {
    return this.pieceMethodDescription(pieceDescription).sortedBufferDescriptions.map(d => d.buffer);
  }

  createBufferGroup(buffer: Piece): FormGroup {
    return this.formBuilder.group({
      buffer: [buffer],
      fiveCycles: [false],
      maxTwistLength: [2],      
      stayWithSolvedBuffer: [false],
      canDoParityTwists: [false],
      doUnorientedBeforeParity: [true],
      doUnorientedBeforeParityTwist: [true],
    });
  }

  onAddBuffer(pieceDescription: PieceDescription) {
    const control = this.sortedBufferDescriptionsControl(pieceDescription);
    const suggestedNextBuffer = find(pieceDescription.pieces, piece => control.value.every((p: BufferDescription) => p.buffer.pieceId !== piece.pieceId));
    control.push(this.createBufferGroup(forceValue(suggestedNextBuffer)));
  }

  onRemoveBuffer(pieceDescription: PieceDescription, index: number) {
    this.sortedBufferDescriptionsControl(pieceDescription).removeAt(index);
  }

  get pieceDescriptions() {
    return this.form?.value?.executionOrder === ExecutionOrder.CE ? [CORNER, EDGE] : [EDGE, CORNER];
  }

  get executionOrderEnum(): typeof ExecutionOrder {
    return ExecutionOrder;
  }

  get pieceMethodDescriptionsControl(): FormArray {
    return this.form.get('pieceMethodDescriptions')! as FormArray;
  }

  canFloat(pieceDescription: PieceDescription): boolean {
    return this.sortedBufferDescriptionsControls(pieceDescription).length > 1;
  }

  canDoParityTwists(pieceDescription: PieceDescription, index: number): boolean {
    return this.sortedBufferDescriptionsControls(pieceDescription)[index].value.canDoParityTwists;
  }

  sortedBufferDescriptionsControl(pieceDescription: PieceDescription): FormArray {
    return this.pieceMethodDescriptionControl(pieceDescription).get('sortedBufferDescriptions')! as FormArray;
  }

  sortedBufferDescriptionsControls(pieceDescription: PieceDescription): readonly FormGroup[] {
    return this.sortedBufferDescriptionsControl(pieceDescription).controls as FormGroup[];
  }

  get value(): MethodDescription {
    return this.form.value;
  }

  pieceMethodDescription(pieceDescription: PieceDescription): PieceMethodDescription {
    return forceValue(find(this.value.pieceMethodDescriptions, d => d.pluralName === pieceDescription.pluralName));
  }

  pieceMethodDescriptionControl(pieceDescription: PieceDescription): FormGroup {
    return this.pieceMethodDescriptionsControl.controls.find(c => c.get('pluralName')!.value === pieceDescription.pluralName) as FormGroup;
  }

  onCalculate() {
    this.submitMethodDescription.emit(this.value);
  }
}
