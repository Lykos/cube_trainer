import { Component } from '@angular/core';
import { CONTACT_EMAIL } from '../contact/contact.component';

// This is separate form the contact component s.t. it can be reused in other places.
@Component({
  selector: 'cube-trainer-contact-content',
  templateUrl: './contact-content.component.html',
})
export class ContactContentComponent {
  get contactEmail() {
    return CONTACT_EMAIL;
  }
}
