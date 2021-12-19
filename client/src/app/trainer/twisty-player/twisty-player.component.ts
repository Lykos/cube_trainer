import { Component, OnInit } from '@angular/core';
import { TwistyPlayer } from 'cubing/twisty';
import { parseAlg } from 'cubing/alg';
import { randomScrambleForEvent } from 'cubing/scramble';

@Component({
  selector: 'app-twisty-player',
  templateUrl: './twisty-player.component.html',
  styleUrls: ['./twisty-player.component.css']
})
export class TwistyPlayerComponent implements OnInit {


  private isValidCubeSize(cubeSize: number) {
    return cubeSize >= 2 && cubeSize <= 7 && Number.isInteger(cubeSize);
  }

  // This is currently in no way useful, it's just here to debug including cubing.js
  randomScramble(cubeSize: number) {
    if (!this.isValidCubeSize(cubeSize)) {
      throw new Error(`invalid cube size ${cubeSize}`);
    }
    const puzzle = `${cubeSize}${cubeSize}${cubeSize}`; // For example 333
    randomScrambleForEvent(puzzle).then(scramble => console.log(scramble));
  }

  
  // This is currently in no way useful, it's just here to debug including cubing.js
  createTwistyPlayer() {
    new TwistyPlayer({
      puzzle: "4x4x4",
      alg: parseAlg("R U R'"),
      hintFacelets: "none",
      backView: "top-right",
      background: "none"
    });
  }

  ngOnInit(): void {
    this.randomScramble(3);
  }

}
