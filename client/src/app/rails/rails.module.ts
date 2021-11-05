import { RailsService } from './rails.service';
import { RawRailsService } from './raw-rails.service';
import { NgModule } from '@angular/core';

@NgModule({
  providers: [
    RailsService,
    RawRailsService,
  ],
})
export class RailsModule {}
