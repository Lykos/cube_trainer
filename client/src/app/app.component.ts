import { Component } from '@angular/core';
import { ToolbarComponent } from '@core/toolbar/toolbar.component';
import { FooterComponent } from '@core/footer/footer.component';
import { RouterOutlet } from '@angular/router'

@Component({
  selector: 'cube-trainer',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  imports: [ToolbarComponent, FooterComponent, RouterOutlet],
})
export class AppComponent {
}
