import { RailsModule } from '../rails/rails.module';
import { UserService } from './user.service';
import { NgModule } from '@angular/core';

@NgModule({
  imports: [
    RailsModule,
  ],
  providers: [
    UserService,
  ],
})
export class UserModule {}
