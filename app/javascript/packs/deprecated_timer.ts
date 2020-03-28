import { Timer } from '../timer/timer';

declare global {
  interface Window { Timer: any; }
}
window.Timer = Timer;
