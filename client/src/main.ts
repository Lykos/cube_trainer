import { enableProdMode } from '@angular/core';

import { AppComponent } from './app/app.component';
import { environment } from './environments/environment';

if (environment.production) {
  enableProdMode();
}

bootstrapApplication(AppComponent)
  .catch(err => console.error(err));
