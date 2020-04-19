import { BrowserModule } from '@angular/platform-browser';
import { RailsModule } from '../rails/rails.module';
import { UsersModule } from '../users/users.module';
import { UniqueModeNameValidator } from './unique-mode-name.validator';
import { ModesService } from './modes.service';
import { RxReactiveFormsModule } from "@rxweb/reactive-form-validators"
import { ModesComponent } from './modes.component';
import { NewModeComponent } from './new-mode.component';
import { NgModule } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatStepperModule } from '@angular/material/stepper';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatFormFieldModule } from '@angular/material/form-field';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { CdkStepperModule } from '@angular/cdk/stepper';

@NgModule({
  declarations: [
    ModesComponent,
    NewModeComponent,
  ],
  imports: [
    BrowserModule,
    RailsModule,
    MatSnackBarModule,
    UsersModule,
    MatTableModule,
    RouterModule,
    MatButtonModule,
    MatStepperModule,
    CdkStepperModule,
    MatTableModule,
    MatCardModule,
    MatInputModule,
    MatFormFieldModule,
    MatSelectModule,
    MatCheckboxModule,
    FormsModule,
    ReactiveFormsModule,
    RxReactiveFormsModule,
  ],
  providers: [
    ModesService,
    UniqueModeNameValidator,
  ],
  exports: [
    ModesComponent,
    NewModeComponent,
  ],
})
export class ModesModule {}
