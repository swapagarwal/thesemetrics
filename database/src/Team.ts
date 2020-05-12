import {
  Column,
  Entity,
  JoinTable,
  ManyToMany,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm'
import { IProject, Project } from './Project'
import { IUser, User } from './User'

export enum TeamType {
  INDIVIDUAL = 'individual',
  ORGANIZATION = 'organization',
}

@Entity()
export class Team {
  @PrimaryGeneratedColumn() id!: number

  @Column() type!: TeamType
  @Column() name!: string
  @Column() createdAt!: Date
  @Column() updatedAt!: Date

  @OneToMany(() => Project, (project: IProject) => project.team)
  projects?: IProject[]

  @ManyToMany(() => User) @JoinTable() members?: IUser[]
}

export interface ITeam extends Team {}
