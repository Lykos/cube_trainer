import { Piece } from '../../utils/cube-stats/piece';
import { zip, find } from '../../utils/utils';
import { forceValue } from '../../utils/optional';
import { ExecutionOrder, MethodDescription, BufferDescription } from '../../utils/cube-stats/method-description';
import { CORNER, EDGE, PieceDescription } from '../../utils/cube-stats/piece-description';
import { Component, Output, EventEmitter } from '@angular/core';
import { FormBuilder, FormGroup, FormArray } from '@angular/forms';

const EDGE_NAMES = ['UF', 'UR', 'UL', 'UB', 'FR', 'FL', 'DF', 'DB', 'DR', 'DL', 'RB', 'LB'];
const CORNER_NAMES = ['UFR', 'UBR', 'UFL', 'UBL', 'DFR', 'DBR', 'DFL', 'DBL'];

interface PieceWithName {
  readonly piece: Piece;
  readonly name: string;
}

function pieceWithName([piece, name]: [Piece, string]) {
  return { piece, name };
}

// Note that the mapping between these and the pieces surprisingly doesn't matter.
// We need to have a mapping, but the calculations don't really care which is which, so any mapping works.
const EDGES: PieceWithName[] = zip(EDGE.pieces, EDGE_NAMES).map(pieceWithName);
const CORNERS: PieceWithName[] = zip(CORNER.pieces, CORNER_NAMES).map(pieceWithName);

@Component({
  selector: 'cube-trainer-method-description-form',
  templateUrl: './method-description-form.component.html',
  styleUrls: ['./method-description-form.component.css']
})
export class MethodDescriptionFormComponent {
  pieces(pieceDescription: PieceDescription): PieceWithName[] {
    if (pieceDescription === EDGE) {
      return EDGES;
    } else if (pieceDescription === CORNER) {
      return CORNERS;
    } else {
      throw new Error('unknown piece description');
    }
  }

  get cornerNames() {
    return CORNER_NAMES;
  }

  @Output()
  private submitMethodDescription: EventEmitter<MethodDescription> = new EventEmitter();

  readonly form: FormGroup;

  constructor(private readonly formBuilder: FormBuilder) {
    this.form = this.formBuilder.group({
      executionOrder: [ExecutionOrder.EC],
      pieceMethodDescriptions: this.formBuilder.array(this.pieceDescriptions.map(p => {
        return this.formBuilder.group({
          pluralName: [p.pluralName],
          maxFloatingTwistLength: [0],
          sortedBufferDescriptions: this.formBuilder.array([this.createBufferGroup(p.pieces[0])]),
          avoidUnorientedIfWeCanFloat: [false],
        });
      })),
    });
  }

  createBufferGroup(buffer: Piece): FormGroup {
    return this.formBuilder.group({
      buffer: [buffer],
      fiveCycles: [false],
      maxTwistLength: [2],      
      stayWithSolvedBuffer: [false],
      canDoParityTwists: [false],
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
    return [CORNER, EDGE];
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

  sortedBufferDescriptionsControl(pieceDescription: PieceDescription): FormArray {
    return this.pieceMethodDescriptionControl(pieceDescription).get('sortedBufferDescriptions')! as FormArray;
  }

  sortedBufferDescriptionsControls(pieceDescription: PieceDescription): readonly FormGroup[] {
    return this.sortedBufferDescriptionsControl(pieceDescription).controls as FormGroup[];
  }

  pieceMethodDescriptionControl(pieceDescription: PieceDescription): FormGroup {
    return this.pieceMethodDescriptionsControl.controls.find(c => c.get('pluralName')!.value === pieceDescription.pluralName) as FormGroup;
  }

  onCalculate() {
    this.submitMethodDescription.emit(this.form.value);
  }
}
