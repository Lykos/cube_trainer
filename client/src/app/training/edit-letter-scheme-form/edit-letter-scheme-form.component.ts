import { MatSnackBar } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { Component, OnInit, Input } from '@angular/core';
import { FormBuilder, FormGroup, AbstractControl } from '@angular/forms';
import { LetterScheme } from '../letter-scheme.model';
import { NewLetterScheme } from '../new-letter-scheme.model';
import { LetterSchemeMapping, WingLetteringMode } from '../letter-scheme-base.model';
import { LetterSchemesService } from '../letter-schemes.service';
import { PartType, PartTypeName } from '../part-type.model';
import { of } from 'rxjs';
import { Optional, ifPresent, none } from '@utils/optional';
import { catchError } from 'rxjs/operators';
import { SharedModule } from '@shared/shared.module';

@Component({
  selector: 'cube-trainer-edit-letter-scheme-form',
  templateUrl: './edit-letter-scheme-form.component.html',
  styleUrls: ['./edit-letter-scheme-form.component.css'],
  imports: [SharedModule],
})
export class EditLetterSchemeFormComponent implements OnInit {
  letterSchemeForm: FormGroup;

  @Input()
  existingLetterScheme: Optional<LetterScheme> = none;

  @Input()
  partTypes: PartType[] = [];

  constructor(private readonly formBuilder: FormBuilder,
              private readonly letterSchemesService: LetterSchemesService,
	      private readonly snackBar: MatSnackBar,
	      private readonly router: Router) {
    this.letterSchemeForm =
      this.formBuilder.group({
        wingLetteringMode: [WingLetteringMode.LikeEdges],
        xcentersLikeCorners: [true],
        tcentersLikeEdges: [true],
        midgesLikeEdges: [true],
        invertWingLetter: [false],      
        invertTwists: [false],      
    })
  }

  relevantInvalid(control: AbstractControl) {
    return control.invalid && (control.dirty || control.touched);
  }

  ngOnInit() {
    this.partTypes.forEach(partType => {
      partType.parts.forEach(part => {
        this.letterSchemeForm.addControl(part.key, this.formBuilder.control(''));
      });
    });
    ifPresent(
      this.existingLetterScheme,
      letterScheme => {
	this.letterSchemeForm.get('wingLetteringMode')!.setValue(letterScheme.wingLetteringMode);
	this.letterSchemeForm.get('xcentersLikeCorners')!.setValue(letterScheme.xcentersLikeCorners);
	this.letterSchemeForm.get('tcentersLikeEdges')!.setValue(letterScheme.tcentersLikeEdges);
	this.letterSchemeForm.get('midgesLikeEdges')!.setValue(letterScheme.midgesLikeEdges);
	this.letterSchemeForm.get('invertWingLetter')!.setValue(letterScheme.invertWingLetter);
	this.letterSchemeForm.get('invertTwists')!.setValue(letterScheme.invertTwists);
	for (let mapping of letterScheme.mappings) {
	  this.letterSchemeForm.get(mapping.part.key)!.setValue(mapping.letter);
	}
      }
    );
  }

  get likeEdges() {
    return WingLetteringMode.LikeEdges;
  }

  get likeCorners() {
    return WingLetteringMode.LikeCorners;
  }

  get custom() {
    return WingLetteringMode.Custom;
  }

  get customizedPartTypes(): PartType[] {
    return this.partTypes.filter(p => this.customized(p));
  }

  private customized(partType: PartType): boolean {
    if (partType.name === PartTypeName.Wing && !this.hasCustomizedWingLetters) {
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

  get hasCustomizedWingLetters() {
    return this.wingLetteringMode === WingLetteringMode.Custom;
  }

  get invertWingLetter() {
    return !this.hasCustomizedWingLetters && this.letterSchemeForm!.get('invertWingLetter')!.value;
  }

  get invertTwists() {
    return this.letterSchemeForm!.get('invertTwists')!.value;
  }

  get wingLetterLike() {
    switch (this.wingLetteringMode) {
      case WingLetteringMode.LikeEdges:
	return 'edge FU';
      case WingLetteringMode.LikeCorners:
	return 'corner FUR';
      default:
	throw new Error(`Unsupported wing lettering mode for inverting wing letters: ${this.wingLetteringMode}`);
    }
  }

  get invertWingLetterLike() {
    switch (this.wingLetteringMode) {
      case WingLetteringMode.LikeEdges:
	return 'edge UF';
      case WingLetteringMode.LikeCorners:
	return 'corner UFR';
      default:
	throw new Error(`Unsupported wing lettering mode for inverting wing letters: ${this.wingLetteringMode}`);
    }
  }

  get newLetterScheme(): NewLetterScheme {
    const mappings: LetterSchemeMapping[] = [];
    for (let partType of this.customizedPartTypes) {
      for (let part of partType.parts) {
        const letter = this.letterSchemeForm.get(part.key)!.value;
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
      invertWingLetter: this.invertWingLetter,
      invertTwists: this.invertTwists,
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
