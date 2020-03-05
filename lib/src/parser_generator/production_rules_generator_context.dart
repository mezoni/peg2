part of '../../parser_generator.dart';

class ProductionRulesGeneratorContext {
  Map<String, Variable> arguments = {};

  final BlockOperation block;

  Variable result;

  Map<Variable, Variable> savedVariables = {};

  Map<Variable, Variable> variables = {};

  final _utils = OperationUtils();

  ProductionRulesGeneratorContext(this.block);

  Variable addArgument(String name, Variable variable) {
    if (arguments.containsKey(name)) {
      throw StateError('Argument not found: $name');
    }

    arguments[name] = variable;
    return variable;
  }

  Variable addVariable(
      BlockOperation block, VariableAllocator va, Variable variable) {
    var result = variables[variable];
    if (result != null) {
      return result;
    }

    result = va.newVar(block, 'final', _utils.varOp(variable));
    variables[variable] = result;
    return result;
  }

  ProductionRulesGeneratorContext copy(BlockOperation block,
      [Iterable<Variable> variables]) {
    final result = ProductionRulesGeneratorContext(block);
    if (variables != null) {
      for (final variable in variables) {
        final value = this.variables[variable];
        if (value != null) {
          result.variables[variable] = value;
        }
      }
    }

    result.arguments = arguments;
    return result;
  }

  Variable getArgument(String name) {
    final result = arguments[name];
    if (result == null) {
      throw StateError('Argument not found: $name');
    }

    return result;
  }

  Variable getVariable(Variable variable) {
    final result = variables[variable];
    if (result == null) {
      throw StateError('Variable not found: ${variable}');
    }

    return result;
  }

  void restoreVariables(BlockOperation block) {
    for (final key in savedVariables.keys) {
      final value = savedVariables[key];
      _utils.addAssign(block, _utils.varOp(key), _utils.varOp(value));
    }
  }

  Variable saveVariable(
      BlockOperation block, VariableAllocator va, Variable variable) {
    if (savedVariables.containsKey(variable)) {
      throw StateError('Variable alraedy saved: ${variable}');
    }

    var result = variables[variable];
    result ??= va.newVar(block, 'final', _utils.varOp(variable));
    variables[variable] = result;
    savedVariables[variable] = result;
    return result;
  }

  Variable tryGetVariable(Variable variable) {
    return variables[variable];
  }
}