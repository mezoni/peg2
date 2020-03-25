part of '../../expressions.dart';

abstract class Expression {
  static final SparseBoolList allChararcters = SparseBoolList()
    ..addGroup(GroupedRangeList<bool>(0, 0x10ffff, true));

  bool canMatchEof = false;

  int id;

  int index;

  bool isSilentMode = false;

  bool isLast = false;

  bool isOptional = false;

  bool isProductive = false;

  bool isSuccessful = false;

  int level;

  Expression parent;

  String returnType = 'dynamic';

  ProductionRule rule;

  final SparseBoolList startCharacters = SparseBoolList();

  final Set<ProductionRule> startTerminals = {};

  String variable;

  bool used;

  void accept(ExpressionVisitor visitor);

  void visitChildren(ExpressionVisitor visitor) {
    //
  }
}
