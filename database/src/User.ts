import {
  Column,
  Entity,
  JoinTable,
  ManyToMany,
  PrimaryGeneratedColumn,
} from 'typeorm'
import { ITeam, Team } from './Team'

@Entity()
export class User {
  @PrimaryGeneratedColumn() id!: number
  @Column() name!: string
  @Column() email!: string
  @Column({ type: 'jsonb' }) preferences!: Record<string, any>
  @Column() createdAt!: Date
  @Column() updatedAt!: Date
  @Column() lastLoginAt?: Date

  @ManyToMany(() => Team) @JoinTable({ name: 'team_member' }) teams?: ITeam[]
}

export interface IUser extends User {}
