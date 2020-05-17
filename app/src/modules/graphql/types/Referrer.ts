import { ObjectType, Field, Int, registerEnumType } from '@nestjs/graphql';
import { GraphQLDate } from '@/modules/graphql/types/base';
import { ReferrerKind } from '@thesemetrics/database';

registerEnumType(ReferrerKind, { description: 'TODO: add description', name: 'ReferrerKind' });

export { ReferrerKind };

@ObjectType({ description: 'TODO: add description' })
export class ReferrerStats {
  @Field(() => GraphQLDate, { description: 'TODO: add description' }) date!: Date;
  @Field({ description: 'TODO: add description' }) referrerKind!: ReferrerKind;
  @Field({ description: 'TODO: add description' }) referrer!: string;
  @Field({ description: 'TODO: add description' }) path!: string;
  @Field(() => Int, { description: 'TODO: add description' }) count!: number;
  @Field(() => Int, { description: 'TODO: add description' }) uniqueCount!: number;
}
