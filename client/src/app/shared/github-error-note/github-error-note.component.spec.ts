import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GithubErrorNoteComponent } from './github-error-note.component';

describe('GithubErrorNoteComponent', () => {
  let component: GithubErrorNoteComponent;
  let fixture: ComponentFixture<GithubErrorNoteComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
    imports: [GithubErrorNoteComponent]
});
    fixture = TestBed.createComponent(GithubErrorNoteComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
