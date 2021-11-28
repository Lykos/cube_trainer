import { Component } from '@angular/core';
import { METADATA } from '../metadata.const';

// This is separate form the contact component s.t. it can be reused in other places.
@Component({
  selector: 'cube-trainer-contact-content',
  templateUrl: './contact-content.component.html',
})
export class ContactContentComponent {
  get contactEmail() {
    return METADATA.maintainer.email;
  }

  get securityEmail() {
    return METADATA.maintainer.securityEmail;
  }

  get newIssueLink() {
    return METADATA.newIssueLink;
  }
}
