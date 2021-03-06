part of '../../expressions.dart';

abstract class SymbolExpression extends Expression {
  final String name;

  bool memoize = false;

  OrderedChoiceExpression? expression;

  SymbolExpression(this.name) {
    if (name.isEmpty) {
      throw ArgumentError('Name should not be emptry');
    }
  }

  @override
  String toString() => name;
}
