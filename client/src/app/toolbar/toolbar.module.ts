import { NgModule } from '@angular/core';
import { ToolbarComponent } from './toolbar.component';
import { UsersModule } from '../users/users.module';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatBadgeModule } from '@angular/material/badge';

@NgModule({
  declarations: [
    ToolbarComponent,
  ],
  imports: [
    BrowserModule,
    MatToolbarModule,
    BrowserAnimationsModule,
    UsersModule,
    MatButtonModule,
    MatBadgeModule,
  ],
  exports: [
    ToolbarComponent,
  ],
  providers: [],
})
export class ToolbarModule {}
