import { DateScalarMode, CustomScalar, Scalar } from '@nestjs/graphql';
import { ValueNode, Kind } from 'graphql';

@Scalar('Date', () => Date)
export class GraphQLDate implements CustomScalar<string, Date> {
  description = 'TODO: add description';

  parseValue(value: string): Date {
    return new Date(`${value}T00:00:00.000Z`);
  }

  serialize(value: Date): string {
    return value.toISOString().split('T')[0];
  }

  parseLiteral(ast: ValueNode) {
    if (ast.kind === Kind.STRING) {
      return this.parseValue(ast.value);
    }

    return null;
  }
}
