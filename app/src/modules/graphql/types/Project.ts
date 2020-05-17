import { Field, ID, ObjectType, registerEnumType } from '@nestjs/graphql';
import { ProjectType } from '@/modules/db';

registerEnumType(ProjectType, { name: 'ProjectType', description: 'TODO: add description' });

export { ProjectType }

@ObjectType({
  description: 'TODO: add description',
})
export class Project {
  @Field(() => ID, { description: 'TODO: add description' }) id!: string;
  @Field({ description: 'TODO: add description' }) name!: string;
  @Field({ description: 'TODO: add description' }) domain!: string;
  @Field({ description: 'TODO: add description' }) preferences!: ProjectPreferences;
}

@ObjectType({
  description: 'TODO: add description',
})
export class ProjectPreferences {}
