import {
  Column,
  Entity,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm'
import { IProjectEvent, ProjectEvent } from './ProjectEvent'
import { ITeam, Team } from './Team'

export enum ProjectType {
  WEBSITE = 'website',
}

@Entity()
export class Project {
  @PrimaryGeneratedColumn() id!: number

  @Column() type!: ProjectType
  @Column() name!: string
  @Column() domain?: string
  @Column() createdAt!: Date
  @Column() updatedAt!: Date

  @ManyToOne(() => Team, (team) => team.projects) team?: ITeam

  @OneToMany(() => ProjectEvent, (event: IProjectEvent) => event.project)
  events?: IProjectEvent
}

export interface IProject extends Project {}
