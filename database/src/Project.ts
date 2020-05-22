import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { ITeam, Team } from './Team';

export enum ProjectType {
  WEBSITE = 'website',
}

export interface ProjectPreferences {}

@Entity()
export class Project {
  @PrimaryGeneratedColumn() id!: number;

  @Column() name!: string;
  @Column() type!: ProjectType;
  @Column() domain!: string;
  @Column({ type: 'jsonb' }) preferences!: ProjectPreferences;
  @Column({ type: 'timestamp with time zone' }) createdAt!: Date;
  @Column({ type: 'timestamp with time zone' }) updatedAt!: Date;

  @ManyToOne(() => Team, (team) => team.projects) team?: ITeam;
}

export interface IProject extends Project {}
