import { AppRoutingModule } from './app-routing.module';
import { Component } from '@angular/core';
import { ToolbarComponent } from '@core/toolbar/toolbar.component';
import { FooterComponent } from '@core/footer/footer.component';

@Component({
  selector: 'cube-trainer',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  imports: [ToolbarComponent, FooterComponent, AppRoutingModule],
})
export class AppComponent {
}
