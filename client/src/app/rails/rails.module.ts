import { RailsService } from './rails.service';
import { CableService } from './cable.service';
import { HttpClientModule } from '@angular/common/http';
import { RawRailsService } from './raw-rails.service';
import { NgModule } from '@angular/core';

@NgModule({
  imports: [
    HttpClientModule,
  ],
  providers: [
    RailsService,
    RawRailsService,
    CableService,
  ],
})
export class RailsModule {}
