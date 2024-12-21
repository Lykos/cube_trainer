import { TestBed } from '@angular/core/testing';
import { AppComponent } from './app.component';
import { FooterComponent } from '@core/footer/footer.component';
import { MatToolbarModule } from '@angular/material/toolbar';

describe('AppComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
    imports: [
        MatToolbarModule,
        AppComponent,
        FooterComponent
    ],
}).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should render title', () => {
    const fixture = TestBed.createComponent(AppComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#toolbar')?.textContent).toContain('Loading toolbar...');
  });
});
