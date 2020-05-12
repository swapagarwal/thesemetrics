import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm'
import { IProject, Project } from './Project'

@Entity({ name: 'event' })
export class ProjectEvent {
  @PrimaryGeneratedColumn() id!: number

  @Column() name!: string
  @Column() batchId?: string

  @Column() resource!: string
  @Column() referrer?: string
  @Column() source?: string
  @Column() medium?: string
  @Column() campaign?: string

  @Column() device?: string
  @Column() deviceType?: string
  @Column() screenSize?: number

  @Column() browser?: string
  @Column() browserVersion?: string

  @Column() os?: string
  @Column() osVersion?: string

  @Column() country?: string

  @Column() userTimeZone?: string
  @Column({ type: 'time without time zone' }) userTimestamp?: Date

  @Column({ type: 'jsonb' }) data!: Record<string, any>

  @Column() createdAt!: Date

  @ManyToOne(() => Project, (project: IProject) => project.events)
  project?: IProject
}

export interface IProjectEvent extends ProjectEvent {}
