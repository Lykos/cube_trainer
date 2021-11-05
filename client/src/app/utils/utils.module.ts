import { BrowserModule } from '@angular/platform-browser';
import { InstantPipe } from './instant.pipe';
import { DurationPipe } from './duration.pipe';
import { NgModule } from '@angular/core';

@NgModule({
  declarations: [
    InstantPipe,
    DurationPipe,
  ],
  imports: [
    BrowserModule,
  ],
  exports: [
    InstantPipe,
    DurationPipe,
  ],
})
export class UtilsModule {}
