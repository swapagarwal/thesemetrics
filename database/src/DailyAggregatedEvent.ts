import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm'
import { IProject, Project } from './Project'

@Entity({ name: 'event' })
export class DailyAggregatedEvent {
  @PrimaryGeneratedColumn() id!: string

  @Column() date!: Date
  @Column() kind!: string
  @Column() value!: string
  @Column({ type: 'jsonb' }) data!: Record<string, any>
  @Column() createdAt!: Date

  @ManyToOne(() => Project, (project: IProject) => project.events)
  project?: IProject
}

export interface IProjectEvent extends DailyAggregatedEvent {}
