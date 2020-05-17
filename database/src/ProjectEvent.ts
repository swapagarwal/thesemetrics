import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm'
import { IProject, Project } from './Project'

@Entity({ name: 'event' })
export class ProjectEvent {
  @PrimaryGeneratedColumn() id!: number

  @Column() name!: string
  @Column() path!: string
  @Column() session?: string

  @Column({ type: 'time without time zone' }) timestamp?: Date

  @Column({ type: 'jsonb' }) data!: Record<string, any>
  @Column() createdOn!: Date

  @ManyToOne(() => Project, (project: IProject) => project.events)
  project?: IProject
}

export interface IProjectEvent extends ProjectEvent {}
