part of '../../expression_analyzers.dart';

class ExpressionResultTypeResolver extends ExpressionVisitor<void> {
  bool _hasModifications = false;

  void resolve(List<ProductionRule> rules) {
    _hasModifications = true;
    while (_hasModifications) {
      _hasModifications = false;
      for (var rule in rules) {
        final expression = rule.expression;
        final returnType = rule.returnType;
        if (returnType != null) {
          _setReturnType(expression, returnType);
        }

        expression.accept(this);
      }
    }
  }

  @override
  void visitAndPredicate(AndPredicateExpression node) {
    node.visitChildren(this);
    _setReturnType(node, 'dynamic');
  }

  @override
  void visitAnyCharacter(AnyCharacterExpression node) {
    node.visitChildren(this);
    _setReturnType(node, 'int');
  }

  @override
  void visitCapture(CaptureExpression node) {
    node.visitChildren(this);
    _setReturnType(node, 'String');
  }

  @override
  void visitCharacterClass(CharacterClassExpression node) {
    node.visitChildren(this);
    _setReturnType(node, 'int');
  }

  @override
  void visitLiteral(LiteralExpression node) {
    node.visitChildren(this);
    _setReturnType(node, 'String');
  }

  @override
  void visitNonterminal(NonterminalExpression node) {
    node.visitChildren(this);
    final rule = _getRule(node.expression!.rule!);
    final returnType = rule.returnType;
    if (returnType == null) {
      final child = rule.expression;
      _setReturnType(node, child.resultType);
    } else {
      _setReturnType(node, returnType);
    }
  }

  @override
  void visitNotPredicate(NotPredicateExpression node) {
    node.visitChildren(this);
    _setReturnType(node, 'dynamic');
  }

  @override
  void visitOneOrMore(OneOrMoreExpression node) {
    node.visitChildren(this);
    final child = node.expression;
    _setReturnType(node, _getListReturnType(child.resultType));
  }

  @override
  void visitOptional(OptionalExpression node) {
    node.visitChildren(this);
    final child = node.expression;
    _setReturnType(node, child.resultType + '?');
  }

  @override
  void visitOrderedChoice(OrderedChoiceExpression node) {
    final expressions = node.expressions;
    final count = expressions.length;
    final returnType = node.resultType;
    for (var i = 0; i < count; i++) {
      final expression = expressions[i];
      _setReturnType(expression, returnType);
    }

    node.visitChildren(this);
    final returnTypes = <String>{};
    for (var i = 0; i < count; i++) {
      final child = expressions[i];
      returnTypes.add(child.resultType);
    }

    if (returnTypes.contains('dynamic')) {
      _setReturnType(node, returnType);
    } else {
      if (returnTypes.length == 1) {
        _setReturnType(node, returnTypes.first);
      } else {
        _setReturnType(node, returnType);
      }
    }
  }

  @override
  void visitSequence(SequenceExpression node) {
    final expressions = node.expressions;
    final count = expressions.length;
    final returnType = node.resultType;
    node.visitChildren(this);
    final variables = expressions.where((e) => e.variable != null).toList();
    if (node.actionIndex != null) {
      _setReturnType(node, returnType);
    } else {
      if (count == 1) {
        final first = expressions.first;
        _setReturnType(node, first.resultType);
      } else {
        if (variables.isEmpty) {
          final expression = expressions.first;
          _setReturnType(node, expression.resultType);
        } else if (variables.length == 1) {
          final expression = variables.first;
          _setReturnType(node, expression.resultType);
        } else {
          final hashSet = variables.toSet();
          if (hashSet.length == 1) {
            final returnType = hashSet.first.resultType;
            _setReturnType(node, _getListReturnType(returnType));
          } else {
            _setReturnType(node, 'List');
          }
        }
      }
    }
  }

  @override
  void visitSubterminal(SubterminalExpression node) {
    node.visitChildren(this);
    final rule = _getRule(node.expression!.rule!);
    final returnType = rule.returnType;
    if (returnType == null) {
      final child = rule.expression;
      _setReturnType(node, child.resultType);
    } else {
      _setReturnType(node, returnType);
    }
  }

  @override
  void visitTerminal(TerminalExpression node) {
    node.visitChildren(this);
    final rule = _getRule(node.expression!.rule!);
    final returnType = rule.returnType;
    if (returnType == null) {
      final child = rule.expression;
      _setReturnType(node, child.resultType);
    } else {
      _setReturnType(node, returnType);
    }
  }

  @override
  void visitZeroOrMore(ZeroOrMoreExpression node) {
    node.visitChildren(this);
    final child = node.expression;
    _setReturnType(node, _getListReturnType(child.resultType));
  }

  String _getListReturnType(String returnType) {
    if (returnType == 'dynamic') {
      return 'List';
    }

    return 'List<$returnType>';
  }

  ProductionRule _getRule(ProductionRule? rule) {
    if (rule != null) {
      return rule;
    }

    throw ArgumentError.notNull('rule');
  }

  void _setReturnType(Expression node, String returnType) {
    int level(String type) {
      switch (type) {
        case 'dynamic':
          return 0;
        case 'List':
          return 1;
        default:
          return 2;
      }
    }

    String normalize(String type) => type.replaceAll(' ', '');
    final prev = normalize(node.resultType);
    final next = normalize(returnType);
    final prevLevel = level(prev);
    final nextLevel = level(next);
    if (prevLevel < nextLevel && prev != next) {
      node.resultType = returnType;
      _hasModifications = true;
    }
  }
}
