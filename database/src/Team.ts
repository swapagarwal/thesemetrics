import {
  Column,
  Entity,
  ManyToMany,
  PrimaryGeneratedColumn,
  JoinTable,
  OneToMany,
} from 'typeorm'
import { User } from './User'
import { Project } from './Project'

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

  @OneToMany(() => Project, (project) => project.team) projects?: Project[]
  @ManyToMany(() => User) @JoinTable() members?: User[]
}
