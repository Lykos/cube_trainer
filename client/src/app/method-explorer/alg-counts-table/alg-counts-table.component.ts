import { Component, Input } from '@angular/core';
import { AlgCountsData, AlgCountsRow } from '../alg-counts-data.model';
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
  styleUrls: ['./alg-counts-table.component.css'],
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
  ],
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
