import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm'
import { IProject, Project } from './Project'

@Entity()
export class DailyAggregateDevice {
  @PrimaryGeneratedColumn() id!: number

  @Column() date!: Date
  @Column() type!: string
  @Column() browser!: string
  @Column() browserVersion!: string
  @Column() os!: string
  @Column() osVersion!: string
  @Column() count!: number

  @ManyToOne(() => Project)
  project?: IProject
}

export interface IDailyAggregateDevice extends DailyAggregateDevice {}
