import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LoggedOutWelcomeComponent } from './logged-out-welcome.component';

describe('LoggedOutWelcomeComponent', () => {
  let component: LoggedOutWelcomeComponent;
  let fixture: ComponentFixture<LoggedOutWelcomeComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ LoggedOutWelcomeComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(LoggedOutWelcomeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
