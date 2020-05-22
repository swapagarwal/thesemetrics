import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { IProject, Project } from './Project';

@Entity({ name: 'pageview' })
export class PageView {
  @PrimaryGeneratedColumn() id!: number;
  @Column() path!: string;
  @Column() unique!: boolean;
  @Column() session?: string;

  @Column() device!: string;
  @Column() deviceType!: string;
  @Column() browser!: string;
  @Column() browserVersion!: string;
  @Column() os!: string;
  @Column() osVersion!: string;
  @Column() screenSize!: number;

  @Column() source?: string;
  @Column() medium?: string;
  @Column() campaign?: string;
  @Column() referrer?: string;

  @Column() country?: string;
  @Column() timezone?: string;
  @Column() timestamp?: Date;

  @Column({ type: 'jsonb' }) data!: Record<string, any>;

  @Column() createdOn!: Date;

  @ManyToOne(() => Project)
  project?: IProject;
}

export interface IPageView extends PageView {}
