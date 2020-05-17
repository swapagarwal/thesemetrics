import { Module } from '@nestjs/common';
import { GraphQLModule as TypeGraphQLModule } from '@nestjs/graphql';
import { GraphQLDate } from '@/modules/graphql/types/base';
import * as Path from 'path';

export { GraphQLDate } from '@/modules/graphql/types/base';
export { DeviceStats } from '@/modules/graphql/types/Device';
export { PageViewStats } from '@/modules/graphql/types/PageView';
export { Project, ProjectPreferences, ProjectType } from '@/modules/graphql/types/Project';
export { ReferrerStats, ReferrerKind } from '@/modules/graphql/types/Referrer';

@Module({
  imports: [
    TypeGraphQLModule.forRoot({
      autoSchemaFile: Path.resolve(__dirname, '../schema.graphql'),
    }),
  ],
  providers: [GraphQLDate],
})
export default class GraphQLModule {}
