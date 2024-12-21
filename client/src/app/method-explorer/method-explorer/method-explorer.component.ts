import { Component } from '@angular/core';
import { MethodDescription } from '@utils/cube-stats/method-description';
import { MethodExplorerService } from '../method-explorer.service';
import { AlgCountsData } from '../alg-counts-data.model';
import { Observable } from 'rxjs';
import { MatTableModule } from '@angular/material/table';
import { CommonModule } from '@angular/common';
import { AlgCountsTableComponent } from '../alg-counts-table/alg-counts-table.component';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { SharedModule } from '@shared/shared.module';
import { MethodDescriptionFormComponent } from '../method-description-form/method-description-form.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'cube-trainer-method-explorer',
  templateUrl: './method-explorer.component.html',
  styleUrls: ['./method-explorer.component.css'],
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
    AlgCountsTableComponent,
    MethodDescriptionFormComponent,
  ],
})
export class MethodExplorerComponent {
  expectedAlgsData$: Observable<AlgCountsData> | undefined = undefined;
  
  constructor(private readonly methodExplorerService: MethodExplorerService) {}

  calculate(methodDescription: MethodDescription) {
    this.expectedAlgsData$ = this.methodExplorerService.expectedAlgCounts(methodDescription);
  }
}
