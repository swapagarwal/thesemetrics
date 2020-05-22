import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm'
import { IProject, Project } from './Project'

@Entity({ name: 'daily_aggregate_pageview' })
export class DailyAggregatePageView {
  @PrimaryGeneratedColumn() id!: number

  @Column() date!: Date
  @Column() path!: string
  @Column() count!: number
  @Column() uniqueCount!: number

  @ManyToOne(() => Project)
  project?: IProject
}

export interface IDailyAggregatePageView extends DailyAggregatePageView {}
