import { Part } from './part.model';

export enum PartTypeName {
  Edge = 'Edge',
  Corner = 'Corner',
  Wing = 'Wing',
  XCenter = 'XCenter',
  TCenter = 'TCenter',
  Midge = 'Midge',
}

export interface PartType {
  readonly name: PartTypeName;
  readonly parts: Part[];
}
