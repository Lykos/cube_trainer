import { TestBed } from '@angular/core/testing';

import { MethodExplorerService } from './method-explorer.service';

describe('MethodExplorerService', () => {
  let service: MethodExplorerService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(MethodExplorerService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
