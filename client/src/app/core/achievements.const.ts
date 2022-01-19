import { Achievement } from './achievement.model';
import { find } from '@utils/utils';
import { Optional } from '@utils/optional';

export const achievements: readonly Achievement[] = [
  {
    id: 'training_session_creator',
    name: 'Training Session Creator',
    description: 'You figured out how to use this website and created your first training session!',
  },
  {
    id: 'statistician',
    name: 'Statistician',
    description: 'You assigned your first stat to a training session!'
  },
  {
    id: 'enthusiast',
    name: 'Enthusiast',
    description: 'You have a training session with more than 100 results!'
  },
  {
    id: 'addict',
    name: 'Addict',
    description: 'You have a training session with more than 1000 results!'
  },
  {
    id: 'professional',
    name: 'Professional',
    description: 'You have a training session with more than 10000 results!'
  },
  {
    id: 'wizard',
    name: 'Wizard',
    description: 'You have a training session with more than 100000 results!'
  },
  {
    id: 'alg_overrider',
    name: 'AlgOverrider',
    description: 'You used an alg override!'
  },
];

export function achievementById(id: string): Optional<Achievement> {
  return find(achievements, a => a.id === id);
}
