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

declare const require: {
  context(path: string, deep?: boolean, filter?: RegExp): {
    keys(): string[];
    <T>(id: string): T;
  };
};

// First, initialize the Angular testing environment.
getTestBed().initTestEnvironment(
  BrowserDynamicTestingModule,
  platformBrowserDynamicTesting(),
);
/*
const trainerIntegrationFile = './app/training/trainer.integration.spec.ts';
const trainerComponentFile = './app/training/trainer/trainer.component.spec.ts';

// TODO: Get rid of the order dependency
function compareAndPutTrainerIntegrationFirst(a: string, b: string) {
  if (a === trainerIntegrationFile && b === trainerIntegrationFile) {
    return 0;
  }
  if (a === trainerIntegrationFile) {
    return -1;
  }
  if (b === trainerIntegrationFile) {
    return 1;
  }
  if (a === trainerComponentFile && b === trainerComponentFile) {
    return 0;
  }
  if (a === trainerComponentFile) {
    return -1;
  }
  if (b === trainerComponentFile) {
    return 1;
  }
  return 0;
}

// Then we find all the tests.
const context = require.context('./', true, /\.spec\.ts$/);
// And load the modules.
context.keys().sort(compareAndPutTrainerIntegrationFirst).map(context);
*/
