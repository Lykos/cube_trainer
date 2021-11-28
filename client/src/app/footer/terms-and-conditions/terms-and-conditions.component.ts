import { Component } from '@angular/core';
import { METADATA } from '../metadata.const';

@Component({
  selector: 'cube-trainer-terms-and-conditions',
  templateUrl: './terms-and-conditions.component.html',
})
export class TermsAndConditionsComponent {
  get securityEmail() {
    return METADATA.maintainer.securityEmail;
  }

  get newIssueLink() {
    return METADATA.newIssueLink;
  }

  scrollToElement(element: HTMLElement): void {
    console.log(element);
    element.scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
  }
}
