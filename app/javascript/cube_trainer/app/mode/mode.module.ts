import { BrowserModule } from '@angular/platform-browser';
import { RailsModule } from '../rails/rails.module';
import { UserModule } from '../user/user.module';
import { ModeService } from './mode.service';
import { ModesComponent } from './modes.component';
import { NgModule } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

@NgModule({
  declarations: [
    ModesComponent,
  ],
  imports: [
    BrowserModule,
    RailsModule,
    UserModule,
    MatTableModule,
    RouterModule,
    MatButtonModule,
    MatTableModule,
    MatCardModule,
    MatCheckboxModule,
    MatInputModule,
    MatFormFieldModule,
    FormsModule,
  ],
  providers: [
    ModeService,
  ],
  exports: [
    ModesComponent,
  ],
})
export class ModeModule {}
