import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EditLetterSchemeComponent } from './edit-letter-scheme.component';

describe('EditLetterSchemeComponent', () => {
  let component: EditLetterSchemeComponent;
  let fixture: ComponentFixture<EditLetterSchemeComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ EditLetterSchemeComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(EditLetterSchemeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
