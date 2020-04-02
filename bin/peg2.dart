import 'dart:io';

import 'package:args/args.dart';
import 'package:lists/lists.dart';
import 'package:path/path.dart' as _path;
import 'package:peg2/expressions.dart';
import 'package:peg2/finite_automaton.dart';
import 'package:peg2/general_parser_generator.dart';
import 'package:peg2/grammar.dart';
import 'package:peg2/grammar_fa_analyzers.dart';
import 'package:peg2/parser_generator.dart';
import 'package:strings/strings.dart';

import 'peg2_parser.dart';

void main(List<String> args) {
  final options = ParserGeneratorOptions();
  final argParser = ArgParser();
  argParser.addFlag('inline-all',
      defaultsTo: false, help: 'Convert all calls into inline expressions');
  argParser.addFlag('inline-nonterminals',
      defaultsTo: false,
      help: 'Convert nonterminal calls into inline expressions');
  argParser.addFlag('inline-subterminals',
      defaultsTo: false,
      help: 'Convert subterminal calls into inline expressions');
  argParser.addFlag('inline-terminals',
      defaultsTo: false,
      help: 'Convert terminal calls into inline expressions');
  argParser.addFlag('memoize',
      defaultsTo: false, help: 'Memoize results of calls');
  argParser.addFlag('optimize-code',
      defaultsTo: true, help: 'Optimize generated code');
  argParser.addFlag('optimize-size',
      defaultsTo: false, help: 'Optimize generated code by size');
  argParser.addOption('parser',
      allowed: ['general', 'postfix'],
      defaultsTo: 'general',
      help: 'Type of generated perser');
  argParser.addFlag('print',
      abbr: 'p', defaultsTo: false, help: 'Print grammar');
  argParser.addFlag('predict',
      defaultsTo: false,
      help:
          'Reduces the number of calls predicted by the start characters of the rules');
  final argResults = argParser.parse(args);
  final printGrammar = argResults['print'] as bool;
  options.inlineNonterminals = argResults['inline-nonterminals'] as bool;
  options.inlineSubterminals = argResults['inline-subterminals'] as bool;
  options.inlineTerminals = argResults['inline-terminals'] as bool;
  options.memoize = argResults['memoize'] as bool;
  options.optimizeCode = argResults['optimize-code'] as bool;
  options.optimizeSize = argResults['optimize-size'] as bool;
  options.parserType = argResults['parser'] as String;
  options.predict = argResults['predict'] as bool;
  if (argResults['inline-all'] as bool) {
    options.inlineNonterminals = true;
    options.inlineSubterminals = true;
    options.inlineTerminals = true;
  }

  String inputFilename;
  String outputFilename;
  if (argResults.rest.length == 1) {
    inputFilename = argResults.rest[0];
    outputFilename = _path.join(_path.dirname(inputFilename),
        _path.basenameWithoutExtension(inputFilename) + '_parser.dart');
  } else if (argResults.rest.length == 2) {
    inputFilename = argResults.rest[0];
    outputFilename = argResults.rest[1];
  } else {
    print('Usage: peg2 options infile [outfile]');
    print('Options:');
    print(argParser.usage);
    exit(-1);
  }

  final inputFile = File(inputFilename);
  if (!inputFile.existsSync()) {
    print('File not found: ${inputFilename}');
    exit(-1);
  }

  final grammarText = inputFile.readAsStringSync();
  final parser = Peg2Parser();
  final grammar = parser.parse(grammarText) as Grammar;
  if (parser.error != null) {
    throw parser.error;
  }

  final errors = [...grammar.errors];
  final warnings = [...grammar.warnings];
  if (errors.isEmpty) {
    _analyzeAndOptimizeGrammar(grammar, options, errors, warnings);
  }

  for (final error in errors) {
    print('Error: $error');
  }

  for (final warning in warnings) {
    print('Warning: $warning');
  }

  if (errors.isNotEmpty) {
    exit(-1);
  }

  if (printGrammar) {
    _printGrammar(grammar);
  }

  final name = _path.basenameWithoutExtension(inputFilename);
  if (name.isEmpty) {
    print('Unable determine parser name');
    exit(-1);
  }

  options.name = camelize(name);
  ParserGenerator parserGenerator;
  if (options.isPostfix()) {
    print('Not implemented yet');
    exit(-1);
    //parserGenerator = PostfixParserGenerator(grammar, options);
    //parserGenerator = ExperimentalParserGenerator(grammar, options);
  } else {
    parserGenerator = GeneralParserGenerator(grammar, options);
  }

  final parserCode = parserGenerator.generate();
  if (parserCode == null) {
    print('Parser generation error');
    exit(-1);
  }

  final outputFile = File(outputFilename);
  outputFile.writeAsStringSync(parserCode);
}

// ignore: unused_element
void _analyzeAndOptimizeGrammar(Grammar grammar, ParserGeneratorOptions options,
    List<String> errors, List<String> warnings) {
  if (errors.isNotEmpty) {
    return;
  }

//final String Function(State<dynamic, dynamic>) _label = null;
  //final label = _label1;
  final start = grammar.start;
  final expressionToEnfaConverter = ExpressionToEnfaConverter();
  final enfa0 = expressionToEnfaConverter.convert(start.expression, _separate0);
  //final enfa1 = expressionToEnfaConverter.convert(start.expression, _separate1);
  final enfaToNfaConverter = ENfaToNfaConverter();
  final nfa0 = enfaToNfaConverter.convert(enfa0);
  //final nfa1 = enfaToNfaConverter.convert(enfa1);
  final nfaToDfaConverter = NfaToDfaConverter();
  final dfa0 = nfaToDfaConverter.convert(nfa0);
  //final dfa1 = nfaToDfaConverter.convert(nfa1);

  /*
  final faToDotConverter = FaToDotConverter();
  final enfaDot0 = faToDotConverter.convert(enfa0, true, label);
  final enfaDot1 = faToDotConverter.convert(enfa1, true, label);
  final nfaDot0 = faToDotConverter.convert(nfa0, false, label);
  final nfaDot1 = faToDotConverter.convert(nfa1, false, label);
  final dfaDot0 = faToDotConverter.convert(dfa0, false, label);
  final dfaDot1 = faToDotConverter.convert(dfa1, false, label);
  File('enfa0.dot').writeAsStringSync(enfaDot0);
  File('enfa1.dot').writeAsStringSync(enfaDot1);
  File('nfa0.dot').writeAsStringSync(nfaDot0);
  File('nfa1.dot').writeAsStringSync(nfaDot1);
  File('dfa0.dot').writeAsStringSync(dfaDot0);
  File('dfa1.dot').writeAsStringSync(dfaDot1);
  */

  final grammarFaAnalyzer = GrammarFaAnalyzer();
  grammarFaAnalyzer.analyze(options, dfa0, errors, warnings);
  //final memoizationRequestsOptimizer = MemoizationRequestsOptimizer();
  //memoizationRequestsOptimizer.optimize(rules);
}

// ignore: unused_element
String _label0(State<dynamic, dynamic> state) {
  String write(Iterable<Expression> expressions) {
    final list = <String>[];
    for (final expression in expressions) {
      final sb = StringBuffer();
      sb.write('[');
      sb.write(expression.rule.name);
      sb.write('(');
      sb.write(expression.runtimeType.toString().substring(0, 3));
      sb.write(' ');
      sb.write(expression.id);
      sb.write(') ');
      var str = expression.toString();
      str = str.replaceAll(r'\', r'\\');
      str = str.replaceAll('"', r'\"');
      sb.write(str);
      sb.write(']');
      list.add(sb.toString());
    }

    return list.join(', ');
  }

  final sb = StringBuffer();
  if (state.isFinal) {
    sb.write('V');
  }

  sb.write(state.id);
  sb.write(r'\n');
  if (state.starts.isNotEmpty) {
    sb.write('starts: ');
    sb.write(write(state.starts));
    sb.write(r'\n');
  }

  if (state.active.isNotEmpty) {
    sb.write('active: ');
    sb.write(write(state.active));
    sb.write(r'\n');
  }

  if (state.ends.isNotEmpty) {
    sb.write('ends: ');
    sb.write(write(state.ends));
    sb.write(r'\n');
  }

  return sb.toString();
}

// ignore: unused_element
String _label1(State<dynamic, dynamic> state) {
  final sb = StringBuffer();
  if (state.isFinal) {
    sb.write('V');
  }

  sb.write(state.id);
  sb.write(r'\n');
  for (final active in state.starts) {
    if (active is OrderedChoiceExpression && active.parent == null) {
      sb.write(active.rule.name);
      sb.write(r'\n');
    }
  }

  return sb.toString();
}

void _printGrammar(Grammar grammar) {
  final sb = StringBuffer();
  final rules = grammar.rules;
  for (var rule in rules) {
    sb.write(rule.name);
    sb.writeln(' =');
    final choice = rule.expression;
    final sequences = choice.expressions;
    final length = sequences.length;
    for (var i = 0; i < length; i++) {
      final sequence = sequences[i];
      if (i > 0) {
        sb.write('  / ');
      } else {
        sb.write('  ');
      }

      sb.writeln(sequence);
    }

    sb.writeln('  ;');
    sb.writeln('');
  }

  print(sb);
}

// ignore: unused_element
void _separate0(SymbolExpression node, EnfaState prev, EnfaState next) {
  // Epsilon move
  prev.states.add(next);
}

// ignore: unused_element
void _separate1(SymbolExpression node, EnfaState prev, EnfaState next) {
  final list = SparseBoolList();
  final marker = 0x110000 + node.id;
  final range = GroupedRangeList(marker, marker, true);
  list.addGroup(range);
  final transitions = prev.transitions;
  for (final group in transitions.getAllSpace(range)) {
    var key = group.key;
    key ??= [];
    if (!key.contains(next)) {
      key.add(next);
    }

    if (group.key == null) {
      final start = group.start;
      final end = group.end;
      final newGroup = GroupedRangeList(start, end, key);
      transitions.addGroup(newGroup);
    }
  }
}
