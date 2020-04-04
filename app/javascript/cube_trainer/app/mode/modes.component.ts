import { Component, OnInit } from '@angular/core';
import { ModeService } from './mode.service';
import { Mode } from './mode';
import { Router } from '@angular/router';

@Component({
  selector: 'modes',
  template: `
<mat-card>
  <mat-card-title>Modes</mat-card-title>
  <mat-card-content>
    <table mat-table [dataSource]="modes">
      <ng-container matColumnDef="name">
        <th mat-header-cell *matHeaderCellDef> Name </th>
        <td mat-cell *matCellDef="let mode"> {{mode.name}} </td>
      </ng-container>
      <tr mat-header-row *matHeaderRowDef="columnsToDisplay; sticky: true"></tr>
      <tr mat-row *matRowDef="let mode; columns: columnsToDisplay" routerLink="/training/'+mode.id"></tr>
    </table>
  </mat-card-content>
  <mat-card-actions>
    <button mat-button color="primary" (click)="onNew()">
      New
    </button>
  </mat-card-actions>
</mat-card>
`
})
export class ModesComponent implements OnInit {
  modes: Mode[] = [];
  columnsToDisplay = ['name'];

  constructor(private readonly modeService: ModeService,
	      private readonly router: Router) {}

  ngOnInit() {
    this.modeService.list().subscribe(modes => {
      console.log(modes);
      this.modes = modes
    });
  }

  onNew() {
    this.router.navigate(['/modes/new']);
  }
}
