import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  ManyToOne,
  OneToMany,
} from 'typeorm'
import { Team } from './Team'
import { ProjectEvent } from './ProjectEvent'

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

  @ManyToOne(() => Team, (team) => team.projects) team?: Team
  @OneToMany(() => ProjectEvent, (event) => event.project) events?: ProjectEvent
}
