import { BrowserModule } from '@angular/platform-browser';
import { RailsModule } from '../rails/rails.module';
import { UserModule } from '../user/user.module';
import { ModeService } from './mode.service';
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
    UserModule,
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
  ],
  providers: [
    ModeService,
  ],
  exports: [
    ModesComponent,
    NewModeComponent,
  ],
})
export class ModeModule {}
