part of '../../expression_analyzers.dart';

class ExpressionInitializer0 extends ExpressionVisitor {
  int _actionIndex;

  int _id;

  int _level;

  ProductionRule _rule;

  Map<String, ProductionRule> _rules;

  void initialize(Grammar grammar) {
    if (grammar == null) {
      throw ArgumentError.notNull('grammar');
    }

    final rules = grammar.rules;
    _rules = <String, ProductionRule>{};
    for (var rule in rules) {
      _rules[rule.name] = rule;
    }

    _actionIndex = 0;
    _id = 0;
    for (var rule in rules) {
      _level = 0;
      _rule = rule;
      final expression = rule.expression;
      expression.accept(this);
    }
  }

  @override
  void visitAndPredicate(AndPredicateExpression node) {
    _initializeNode(node);
  }

  @override
  void visitAnyCharacter(AnyCharacterExpression node) {
    _initializeNode(node);
  }

  @override
  void visitCapture(CaptureExpression node) {
    _initializeNode(node);
  }

  @override
  void visitCharacterClass(CharacterClassExpression node) {
    _initializeNode(node);
  }

  @override
  void visitLiteral(LiteralExpression node) {
    _initializeNode(node);
  }

  @override
  void visitNonterminal(NonterminalExpression node) {
    _initializeSymbol(node);
  }

  @override
  void visitNotPredicate(NotPredicateExpression node) {
    _initializeNode(node);
  }

  @override
  void visitOneOrMore(OneOrMoreExpression node) {
    _initializeNode(node);
  }

  @override
  void visitOptional(OptionalExpression node) {
    _initializeNode(node);
  }

  @override
  void visitOrderedChoice(OrderedChoiceExpression node) {
    final expressions = node.expressions;
    final length = expressions.length;
    for (var i = 0; i < length; i++) {
      final child = expressions[i];
      child.index = i;
    }

    _initializeNode(node);
  }

  @override
  void visitSequence(SequenceExpression node) {
    _assignId(node);
    final expressions = node.expressions;
    final length = expressions.length;
    for (var i = 0; i < length; i++) {
      final child = expressions[i];
      child.index = i;
      _assignId(child);
    }

    _initializeNode(node);
    if (node.actionSource != null) {
      node.actionIndex = _actionIndex++;
    }
  }

  @override
  void visitSubterminal(SubterminalExpression node) {
    _initializeSymbol(node);
  }

  @override
  void visitTerminal(TerminalExpression node) {
    _initializeSymbol(node);
  }

  @override
  void visitZeroOrMore(ZeroOrMoreExpression node) {
    _initializeNode(node);
  }

  void _assignId(Expression node) {
    node.id ??= _id++;
  }

  void _initializeNode(Expression node) {
    if (node is SingleExpression) {
      final child = node.expression;
      child.isLast = true;
    } else if (node is MultipleExpression) {
      final last = node.expressions.last;
      last.isLast = true;
    }

    node.index ??= 0;
    node.rule = _rule;
    _assignId(node);
    node.level = _level;
    final level = _level;
    _level++;
    node.visitChildren(this);
    _level = level;
  }

  void _initializeSymbol(SymbolExpression node) {
    _initializeNode(node);
    final rule = _rules[node.name];
    if (rule == null) {
      throw StateError('Production rule not found: ${node.name}');
    }

    final expression = rule.expression;
    node.expression = expression;
  }
}
