part of '../../expressions.dart';

abstract class MultipleExpression<E extends Expression> extends Expression {
  final List<E> expressions = [];

  MultipleExpression(List<E?> expressions) {
    if (expressions.isEmpty) {
      throw ArgumentError('expressions');
    }

    for (var expression in expressions) {
      if (expression == null) {
        throw ArgumentError('expressions');
      }

      if (expression is! E) {
        throw ArgumentError('expressions');
      }

      expression.parent = this;
      this.expressions.add(expression);
    }
  }

  @override
  void visitChildren<T>(ExpressionVisitor<T> visitor) {
    for (var expression in expressions) {
      expression.accept(visitor);
    }
  }
}
