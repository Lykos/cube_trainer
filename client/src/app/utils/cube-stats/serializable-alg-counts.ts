export interface SerializableAlgCounts {
  readonly cyclesByLength: number[];
  readonly doubleSwaps: number;
  readonly parities: number;
  readonly parityTwists: number;
  readonly twistsByNumUnoriented: number[];
}
