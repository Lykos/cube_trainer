import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SelectStatsComponent } from './select-stats.component';

describe('SelectStatsComponent', () => {
  let component: SelectStatsComponent;
  let fixture: ComponentFixture<SelectStatsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
    imports: [SelectStatsComponent]
})
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(SelectStatsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
