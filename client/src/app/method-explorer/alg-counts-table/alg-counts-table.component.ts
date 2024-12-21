import { Component, Input } from '@angular/core';
import { AlgCountsData, AlgCountsRow } from '../alg-counts-data.model';

const DATA_COLUMNS = ['name', 'threeCycles', 'fiveCycles', 'doubleSwaps', 'parities', 'parityTwists', 'totalTwists', 'total'];

class RenderableAlgCountsRow {
  constructor(readonly row: AlgCountsRow) {}

  get pluralName() {
    return this.row.pluralName;
  }

  get threeCycles() {
    return this.row.algCounts.cyclesByLength[3]?.toFixed(2);
  }

  get fiveCycles() {
    return this.row.algCounts.cyclesByLength[5]?.toFixed(2);
  }

  get doubleSwaps() {
    return this.row.algCounts.doubleSwaps.toFixed(2);
  }

  get parities() {
    return this.row.algCounts.parities.toFixed(2);
  }

  get parityTwists() {
    return this.row.algCounts.parityTwists.toFixed(2);
  }

  get twoTwists() {
    return this.row.algCounts.twistsByNumUnoriented[2]?.toFixed(2);
  }
  
  get threeTwists() {
    return this.row.algCounts.twistsByNumUnoriented[3]?.toFixed(2);
  }
  
  get fourTwists() {
    return this.row.algCounts.twistsByNumUnoriented[4]?.toFixed(2);
  }
  
  get totalTwists() {
    return this.row.algCounts.totalTwists.toFixed(2);
  }
  
  get total() {
    return this.row.algCounts.total.toFixed(2);
  }

  [key: string]: any;
}

@Component({
  selector: 'cube-trainer-alg-counts-table',
  templateUrl: './alg-counts-table.component.html',
  styleUrls: ['./alg-counts-table.component.css']
})
export class AlgCountsTableComponent {
  @Input() expectedAlgsData: AlgCountsData | undefined = undefined;

  get expectedAlgsRows(): RenderableAlgCountsRow[] {
    const rows = this.expectedAlgsData ? this.expectedAlgsData.rows : [];
    return rows.map(row => new RenderableAlgCountsRow(row));
  }

  get columnsToDisplay() {
    return ['name'].concat(DATA_COLUMNS.filter(c => this.expectedAlgsRows.some(r => r[c] && r[c] > 0)));
  }
}
