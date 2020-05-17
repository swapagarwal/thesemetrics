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

export enum Plan {
  FREE = 'free',
  ANONYMOUS = 'anonymous',
}

@Entity()
export class Team {
  @PrimaryGeneratedColumn() id!: number

  @Column() type!: TeamType
  @Column() name!: string
  @Column() email!: string
  @Column() plan!: Plan
  @Column() stripe?: string
  @Column({ type: 'jsonb' }) preferences!: Record<string, any>

  @Column() createdAt!: Date
  @Column() updatedAt!: Date

  @OneToMany(() => Project, (project: IProject) => project.team)
  projects?: IProject[]

  @ManyToMany(() => User) @JoinTable({ name: 'team_member' }) members?: IUser[]
}

export interface ITeam extends Team {}
