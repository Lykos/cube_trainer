import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, AbstractControl } from '@angular/forms';
import { NewLetterScheme } from '../new-letter-scheme.model';
import { LetterSchemeMapping, WingLetteringMode } from '../letter-scheme-base.model';
import { LetterSchemesService } from '../letter-schemes.service';
import { PartTypesService } from '../part-types.service';
import { PartType, PartTypeName } from '../part-type.model';
import { of } from 'rxjs';
import { catchError } from 'rxjs/operators';

@Component({
  selector: 'cube-trainer-letter-scheme',
  templateUrl: './new-letter-scheme.component.html'
})
export class NewLetterSchemeComponent implements OnInit {
  letterSchemeForm?: FormGroup;
  partTypes!: PartType[];

  constructor(private readonly formBuilder: FormBuilder,
              private readonly partTypesService: PartTypesService,
              private readonly letterSchemesService: LetterSchemesService,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router) {}

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.partTypesService.list().subscribe((partTypes: PartType[]) => {
      this.partTypes = partTypes
      const formGroup: { [key: string]: any; } = {
        wingLetteringMode: [WingLetteringMode.LikeEdges],
        xcentersLikeCorners: [true],
        tcentersLikeEdges: [true],
        midgesLikeEdges: [true],
      };
      partTypes.forEach(partType => {
        partType.parts.forEach(part => {
          formGroup[part.key] = [''];
        });
      });
      this.letterSchemeForm = this.formBuilder.group(formGroup);
    });
  }

  get wingLetteringModeEnum(): typeof WingLetteringMode {
    console.log(this.newLetterScheme);
    return WingLetteringMode;
  }

  get customizedPartTypes(): PartType[] {
    return this.partTypes.filter(p => this.customized(p));
  }

  private customized(partType: PartType): boolean {
    if (partType.name === PartTypeName.Wing && this.wingLetteringMode !== WingLetteringMode.Custom) {
      return false;
    }
    if (partType.name === PartTypeName.XCenter && this.xcentersLikeCorners) {
      return false;
    }
    if (partType.name === PartTypeName.TCenter && this.tcentersLikeEdges) {
      return false;
    }
    if (partType.name === PartTypeName.Midge && this.midgesLikeEdges) {
      return false;
    }
    return true
  }

  get wingLetteringMode(): WingLetteringMode {
    return this.letterSchemeForm!.get('wingLetteringMode')!.value;
  }

  get xcentersLikeCorners() {
    return this.letterSchemeForm!.get('xcentersLikeCorners')!.value;
  }

  get tcentersLikeEdges() {
    return this.letterSchemeForm!.get('tcentersLikeEdges')!.value;
  }

  get midgesLikeEdges() {
    return this.letterSchemeForm!.get('midgesLikeEdges')!.value;
  }

  get newLetterScheme(): NewLetterScheme {
    const mappings: LetterSchemeMapping[] = [];
    for (let partType of this.customizedPartTypes) {
      for (let part of partType.parts) {
        const letter = this.letterSchemeForm!.get(part.key)!.value;
        if (letter) {
          mappings.push({part, letter});
        }
      }
    }
    return {
      wingLetteringMode: this.wingLetteringMode,
      xcentersLikeCorners: this.xcentersLikeCorners,
      tcentersLikeEdges: this.tcentersLikeEdges,
      midgesLikeEdges: this.midgesLikeEdges,
      mappings,
    };
  }

  onSubmit() {
    let message = 'Letter scheme overwritten!'
    this.letterSchemesService.destroy()
      .pipe(catchError((e: any) => {
        message = 'Letter scheme created!';
        return of(undefined);
      }))
      .subscribe(r => {
        this.letterSchemesService.create(this.newLetterScheme).subscribe(r => {
          this.snackBar.open(message, 'Close');
          this.router.navigate(['/user']);
        });
      });
  }
}
