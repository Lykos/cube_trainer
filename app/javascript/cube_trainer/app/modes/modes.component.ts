import { Component, OnInit } from '@angular/core';
import { ModesService } from './modes.service';
import { Mode } from './mode';
import { Router } from '@angular/router';

@Component({
  selector: 'modes',
  template: `
<div>
  <h2>Modes</h2>
  <div>
    <table mat-table class="mat-elevation-z2" [dataSource]="modes">
      <mat-text-column name="name"></mat-text-column>
      <ng-container matColumnDef="numResults">
        <th mat-header-cell *matHeaderCellDef> Number of Results </th>
        <td mat-cell *matCellDef="let mode"> {{mode.numResults}} </td>
      </ng-container>
      <ng-container matColumnDef="use">
        <th mat-header-cell *matHeaderCellDef> Use </th>
        <td mat-cell *matCellDef="let mode">
          <button mat-icon-button (click)="onUse(mode)">
            <span class="material-icons">play_arrow</span>
          </button>
        </td>
      </ng-container>
      <ng-container matColumnDef="delete">
        <th mat-header-cell *matHeaderCellDef> Delete </th>
        <td mat-cell *matCellDef="let mode">
          <button mat-icon-button (click)="onDelete(mode)">
            <span class="material-icons">delete</span>
          </button>
        </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let mode; columns: columnsToDisplay"></tr>
    </table>
  </div>
  <div>
    <button mat-raised-button color="primary" (click)="onNew()">
      New
    </button>
  </div>
</div>
`,
  styles: [`
table {
  width: 100%;
}
`]
})
export class ModesComponent implements OnInit {
  modes: Mode[] = [];
  columnsToDisplay = ['name', 'numResults', 'use', 'delete'];

  constructor(private readonly modesService: ModesService,
	      private readonly router: Router) {}

  onUse(mode: Mode) {
    this.router.navigate([`/trainer/${mode.id}`]);
  }

  ngOnInit() {
    this.modesService.list().subscribe((modes: Mode[]) => this.modes = modes);
  }

  onNew() {
    this.router.navigate(['/modes/new']);
  }

  onDelete(mode: Mode) {
    this.modesService.destroy(mode.id).subscribe(() => {
      this.modesService.list().subscribe((modes: Mode[]) => this.modes = modes);
    });
  }
}
