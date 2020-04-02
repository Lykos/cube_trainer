import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { AppComponent } from './app.component';
import { TrainerModule } from './trainer/trainer.module';
import { ToolbarModule } from './toolbar/toolbar.module';

@NgModule({
  declarations: [
    AppComponent,
  ],
  imports: [
    BrowserModule,
    ToolbarModule,
    TrainerModule,
  ],
  bootstrap: [
    AppComponent,
  ],
})
export class AppModule { }
