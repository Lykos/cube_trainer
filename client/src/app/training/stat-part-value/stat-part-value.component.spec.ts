import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StatPartValueComponent } from './stat-part-value.component';

describe('StatPartValueComponent', () => {
  let component: StatPartValueComponent;
  let fixture: ComponentFixture<StatPartValueComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ StatPartValueComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(StatPartValueComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
