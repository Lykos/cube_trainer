import { Piece } from '../../utils/cube-stats/piece';
import { zip } from '../../utils/utils';
import { ExecutionOrder, MethodDescription } from '../../utils/cube-stats/method-description';
import { CORNER, EDGE, PieceDescription } from '../../utils/cube-stats/piece-description';
import { Component, Output, EventEmitter } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';

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
        const sortedBuffers = [p.pieces[0]];
        const twistsWithCosts = p.twistGroups().filter(g => g.numUnoriented === 2).map(g => {
          return {twistOrientedTypeIndices: g.orientedTypes.map(o => o.index), cost: 1};
        });
        return this.formBuilder.group({
          pluralName: [p.pluralName],
          sortedBuffers: [sortedBuffers],
          twistsWithCosts: [twistsWithCosts],
        });
      })),
    });
  }

  get pieceDescriptions() {
    return [CORNER, EDGE];
  }

  get executionOrderEnum(): typeof ExecutionOrder {
    return ExecutionOrder;
  }

  onCalculate() {
    this.submitMethodDescription.emit(this.form.value);
  }
}
