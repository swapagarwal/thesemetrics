import {
  Column,
  Entity,
  JoinTable,
  ManyToMany,
  PrimaryGeneratedColumn,
} from 'typeorm'
import { Team } from './Team'

@Entity()
export class User {
  @PrimaryGeneratedColumn() id!: number

  @Column() username!: string
  @Column() password!: string
  @Column() createdAt!: Date
  @Column() updatedAt!: Date

  @ManyToMany(() => Team) @JoinTable() teams?: Team[]
}
