import { ObjectType, Field, Int } from '@nestjs/graphql';
import { GraphQLDate } from '@/modules/graphql/types/base';

@ObjectType({ description: 'TODO: add description' })
export class PageViewStats {
  @Field(() => GraphQLDate, { description: 'TODO: add description' }) date!: Date;
  @Field({ description: 'TODO: add description' }) path!: string;
  @Field(() => Int, { description: 'TODO: add description' }) count!: number;
  @Field(() => Int, { description: 'TODO: add description' }) uniqueCount!: number;
}
