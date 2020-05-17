import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm'
import { IProject, Project } from './Project'

export enum ReferrerKind {
  SOURCE = 'source',
  MEDIUM = 'medium',
  CAMPAIGN = 'campaign',
  REFERRER = 'referrer',
  COUNTRY = 'country',
  TIMEZONE = 'timezone',
}

@Entity({ name: 'daily_aggregate_referrer_pageview' })
export class DailyAggregateReferrerPageView {
  @PrimaryGeneratedColumn() id!: number

  @Column() date!: Date
  @Column() referrerKind!: ReferrerKind
  @Column() referrer!: string
  @Column() path!: string
  @Column() count!: number
  @Column() uniqueCount!: number

  @ManyToOne(() => Project, (project: IProject) => project.events)
  project?: IProject
}

export interface IDailyAggregateReferrerPageView extends DailyAggregateReferrerPageView {}
