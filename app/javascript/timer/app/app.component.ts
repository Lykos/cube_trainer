import { Component } from '@angular/core';

@Component({
  selector: 'timer',
  template: `<h1>Hello {{name}}</h1>`
})
export class TimerComponent {
  name = 'Timer!';
}
