import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TrainingSessionComponent } from './training-session.component';

describe('TrainingSessionComponent', () => {
  let component: TrainingSessionComponent;
  let fixture: ComponentFixture<TrainingSessionComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [TrainingSessionComponent]
    });
    fixture = TestBed.createComponent(TrainingSessionComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
