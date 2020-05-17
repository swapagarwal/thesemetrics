import { ObjectType, Field, Int } from '@nestjs/graphql';
import { GraphQLDate } from '@/modules/graphql/types/base';

@ObjectType({ description: 'TODO: add description' })
export class DeviceStats {
  @Field(() => GraphQLDate, { description: 'TODO: add description' }) date!: Date;
  @Field({ description: 'TODO: add description' }) type!: string;
  @Field({ description: 'TODO: add description' }) browserVersion!: string;
  @Field({ description: 'TODO: add description' }) os!: string;
  @Field({ description: 'TODO: add description' }) osVersion!: string;
  @Field(() => Int, { description: 'TODO: add description' }) count!: number;
}
