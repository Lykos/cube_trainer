import { NgModule } from '@angular/core';
import { ToolbarComponent } from './toolbar.component';
import { UserModule } from '../user/user.module';
import { MatToolbarModule } from '@angular/material/toolbar';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

@NgModule({
  declarations: [
    ToolbarComponent,
  ],
  imports: [
    BrowserModule,
    MatToolbarModule,
    BrowserAnimationsModule,
    UserModule,
  ],
  exports: [
    ToolbarComponent,
  ],
  providers: [],
})
export class ToolbarModule {}
