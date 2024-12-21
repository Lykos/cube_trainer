import { Component } from '@angular/core';
import { METADATA } from '@shared/metadata.const';

@Component({
  selector: 'cube-trainer-terms-and-conditions',
  templateUrl: './terms-and-conditions.component.html',
  standalone: false,
})
export class TermsAndConditionsComponent {
  get securityBugEmail() {
    return METADATA.maintainer.securityBugEmail;
  }

  get newSecurityBugLink() {
    return METADATA.newIssueLinks.securityBug;
  }

  get newIssueLink() {
    return METADATA.newIssueLinks.choose;
  }

  scrollToElement(element: HTMLElement): void {
    console.log(element);
    element.scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
  }
}
