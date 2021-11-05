import { Component, OnInit } from '@angular/core';
import { ModesService } from './modes.service';
import { Mode } from './mode';
import { Router } from '@angular/router';
import { DeleteModeConfirmationDialogComponent } from './delete-mode-confirmation-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  selector: 'cube-trainer-modes',
  templateUrl: './modes.component.html',
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
	      private readonly dialog: MatDialog,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router) {}

  onUse(mode: Mode) {
    this.router.navigate([`/trainer/${mode.id}`]);
  }

  ngOnInit() {
    this.update();
  }

  update() {
    this.modesService.list().subscribe((modes: Mode[]) => this.modes = modes);
  }

  onNew() {
    this.router.navigate(['/modes/new']);
  }

  onDelete(mode: Mode) {
    const dialogRef = this.dialog.open(DeleteModeConfirmationDialogComponent, { data: mode });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
	this.snackBar.open(`Mode ${mode.name} deleted`, 'Close');
	this.modesService.destroy(mode.id).subscribe(() => this.update());
      }
    });
  }
}
