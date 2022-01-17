import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LoggedInWelcomeComponent } from './logged-in-welcome.component';

describe('LoggedInWelcomeComponent', () => {
  let component: LoggedInWelcomeComponent;
  let fixture: ComponentFixture<LoggedInWelcomeComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ LoggedInWelcomeComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(LoggedInWelcomeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
