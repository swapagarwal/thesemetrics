import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm'
import { IProject, Project } from './Project'

@Entity({ name: 'event' })
export class ProjectEvent {
  @PrimaryGeneratedColumn() id!: number

  @Column() name!: string
  @Column() resource!: string
  @Column() batch?: string
  @Column() unique!: boolean

  @Column() screenSize!: number
  @Column() device!: string
  @Column() browser!: string
  @Column() browserVersion!: string
  @Column() os!: string
  @Column() osVersion!: string

  @Column() source?: string
  @Column() medium?: string
  @Column() campaign?: string
  @Column() referrer?: string

  @Column() country?: string
  @Column() timeZone?: string
  @Column({ type: 'time without time zone' }) timestamp?: Date

  @Column({ type: 'jsonb' }) data!: Record<string, any>
  @Column() createdAt!: Date

  @ManyToOne(() => Project, (project: IProject) => project.events)
  project?: IProject
}

export interface IProjectEvent extends ProjectEvent {}
