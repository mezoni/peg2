import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import '../../grammar.dart';

abstract class ParserGeneratorBase {
  final Grammar grammar;

  final ParserGeneratorOptions options;

  ParserGeneratorBase(this.grammar, this.options);

  void addClassParser(List<Spec> specs);

  String generate() {
    return _generate();
  }

  void _addComments(List<Spec> specs) {
    specs.add(Code('// Generated by \'peg2\'\n'));
    specs.add(Code('// https://pub.dev/packages/peg2\n\n'));
  }

  void _addGlobals(List<Spec> specs) {
    final globals = grammar.globals;
    if (globals != null) {
      specs.add(Code(globals));
    }
  }

  void _addHints(List<Spec> specs) {
    final hints = <String>[];
    hints.add('// ignore_for_file: non_constant_identifier_names');
    hints.add('// ignore_for_file: unused_element');
    specs.add(Code(hints.join('\n')));
  }

  String _generate() {
    final specs = <Spec>[];
    _addComments(specs);
    _addGlobals(specs);
    addClassParser(specs);
    _addHints(specs);
    final library = Library((b) {
      b.body.addAll(specs);
    });

    final emitter = DartEmitter();
    var result = '${library.accept(emitter)}';
    final formatter = DartFormatter();
    result = formatter.format(result);
    return result;
  }
}
