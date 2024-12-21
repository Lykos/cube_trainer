import { Component } from '@angular/core';

interface Link {
  readonly link: string;
  readonly text: string;
}

@Component({
  selector: 'cube-trainer-navigation-bar',
  templateUrl: './navigation-bar.component.html',
  styleUrls: ['./navigation-bar.component.css']
})
export class NavigationBarComponent {
  links: readonly Link[] = [
    { link: '/training-sessions', text: 'Sessions' },
    { link: '/method-explorer', text: 'Method Explorer' },
  ];
}
