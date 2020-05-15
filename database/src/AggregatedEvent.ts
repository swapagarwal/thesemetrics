import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { IProject, Project } from './Project';

@Entity({ name: 'event' })
export class AggregatedEvent {
  @PrimaryGeneratedColumn() id!: number;

  @Column() kind!: string;
  @Column() value!: string;
  @Column({ type: 'jsonb' }) data!: Record<string, any>;
  @Column() createdAt!: Date;

  @ManyToOne(() => Project, (project: IProject) => project.events)
  project?: IProject;
}

export interface IAggregatedEvent extends AggregatedEvent {}
