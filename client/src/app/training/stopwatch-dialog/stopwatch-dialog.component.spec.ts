import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StopwatchDialogComponent } from './stopwatch-dialog.component';

describe('StopwatchDialogComponent', () => {
  let component: StopwatchDialogComponent;
  let fixture: ComponentFixture<StopwatchDialogComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [StopwatchDialogComponent]
    });
    fixture = TestBed.createComponent(StopwatchDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
