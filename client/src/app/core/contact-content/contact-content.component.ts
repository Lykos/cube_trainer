import { Component } from '@angular/core';
import { METADATA } from '@shared/metadata.const';

// This is separate form the contact component s.t. it can be reused in other places.
@Component({
  selector: 'cube-trainer-contact-content',
  templateUrl: './contact-content.component.html',
})
export class ContactContentComponent {
  get contactEmail() {
    return METADATA.maintainer.email;
  }

  get securityBugEmail() {
    return METADATA.maintainer.securityBugEmail;
  }

  get newFeatureRequestLink() {
    return METADATA.newIssueLinks.featureRequest;
  }

  get newBugLink() {
    return METADATA.newIssueLinks.bug;
  }

  get newSecurityBugLink() {
    return METADATA.newIssueLinks.securityBug;
  }
}
