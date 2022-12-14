// This file is required by karma.conf.js and loads recursively all the .spec and framework files

// This is needed to make fake Jasmine clock work.
(window as any)['__zone_symbol__fakeAsyncPatchLock'] = true;

import 'zone.js';
import 'zone.js/testing';

import { getTestBed } from '@angular/core/testing';
import {
  BrowserDynamicTestingModule,
  platformBrowserDynamicTesting
} from '@angular/platform-browser-dynamic/testing';

// First, initialize the Angular testing environment.
getTestBed().initTestEnvironment(
  BrowserDynamicTestingModule,
  platformBrowserDynamicTesting(),
);
