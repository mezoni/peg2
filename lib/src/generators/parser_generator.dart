part of '../../generators.dart';

class ParserGenerator {
  static const _classes = '''  
class _Memo {
  final int id;

  final int pos;

  final result;

  final bool success;

  _Memo({
    this.id,
    this.pos,
    this.result,
    this.success,
  });  
}
''';

  final Grammar grammar;

  final ParserGeneratorOptions options;

  ParserGenerator(this.grammar, this.options);

  String generate() {
    final grammarAnalyzer = GrammarAnalyzer();
    final grammarErrors = grammarAnalyzer.analyze(grammar);
    if (grammarErrors.isNotEmpty) {
      for (var error in grammarErrors) {
        print(error);
      }

      return null;
    }

    List<MethodOperation> methods;
    if (options.isPostfix()) {
      //throw UnimplementedError();
      final experimentalGenerator = ExperimentalGenerator(grammar, options);
      methods = experimentalGenerator.generate();
    } else {
      final rulesToOperationsBuilder =
          RulesToOperationsGenerator(grammar, options);
      methods = rulesToOperationsBuilder.build();
    }

    for (final method in methods) {
      final operationsInitializer = OperationInitializer();
      operationsInitializer.initialize(method);
    }

    if (options.optimizeCode) {
      for (final method in methods) {
        final operationsOptimizer = OperationOptimizer();
        operationsOptimizer.optimize(method.body);
      }
    }

    final operationsToCodeConverter = OperationsToCodeConverter();
    final methodBuilders = operationsToCodeConverter.convert(methods);
    final libraryBuilder = ContentBuilder();
    _addHeader(libraryBuilder, options);
    final lineSplitter = LineSplitter();
    if (grammar.globals != null) {
      final lines = lineSplitter.convert(grammar.globals);
      if (lines.isNotEmpty && lines[0].isEmpty) {
        lines.removeAt(0);
      }

      libraryBuilder.addAll(lines);
    }

    final parserClassBuilder = ParserClassGenerator(grammar, options);
    parserClassBuilder.build(libraryBuilder, methodBuilders);
    final classes = lineSplitter.convert(_classes);
    libraryBuilder.addAll(classes);
    libraryBuilder.add('// ignore_for_file: prefer_final_locals');
    libraryBuilder.add('// ignore_for_file: unused_element');
    libraryBuilder.add('// ignore_for_file: unused_field');
    libraryBuilder.add('// ignore_for_file: unused_local_variable');
    final formatter = DartFormatter();
    var source = libraryBuilder.build(0).join('\n');
    try {
      source = formatter.format(source);
      // ignore: unused_catch_clause
    } on FormatterException catch (e) {
      //
    }

    return source;
  }

  void _addHeader(ContentBuilder builder, ParserGeneratorOptions options) {
    builder.add('// Generated by \'peg2\'');
    builder.add('// https://pub.dev/packages/peg2');
    builder.add('');
  }
}
