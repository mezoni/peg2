import 'package:code_builder/code_builder.dart'
    show
        Block,
        Class,
        ClassBuilder,
        Code,
        Field,
        FieldModifier,
        Method,
        Parameter,
        Reference;
import 'package:peg2/src/generators/production_rule_name_generator.dart';

import '../../grammar.dart';
import '../helpers/expression_helper.dart';
import '../helpers/type_helper.dart';
import 'bit_flag_generator.dart';
import 'class_members.dart';
import 'members.dart';

abstract class ParserClassGeneratorBase {
  static const _methodParse = '''
    _source = source;
    _reset();
    final result = {{PARSE}}();
        if (!ok) {
      _buildError();
    }

    return result;
''';

  static const _methodBuildError = r"""
    final sink = StringBuffer();
    sink.write('Syntax error, ');
    if (_unterminated != null) {
      sink.write('unterminated ');
      sink.write(_unterminated);
    } else {
      final names = <String>[];
      final flags = <int>[];
      {{ADD_FAILURES}}
      for (var i = 0, id = 0; i < flags.length; i++) {
        final flag = flags[i];
        for (var j = 0; j < 32; j++) {
          final mask = 1 << j;
          if (flag & mask != 0) {
            final name = _terminals[id];
            names.add(name);
          }

          id++;
        }
      }

      names.sort();
      if (names.isEmpty) {
        if (_failStart == _length) {
          sink.write('unexpected end of input');
        } else {
          sink.write('unexpected charcater ');
          final ch = _getChar(_failStart);
          if (ch >= 32 && ch < 126) {
            sink.write('\'');
            sink.write(String.fromCharCode(ch));
            sink.write('\'');
          } else {
            sink.write('(');
            sink.write(ch);
            sink.write(')');
          }
        }
      } else {
        sink.write('expected ');
        sink.write(names.join(', '));
      }
    }

    error = FormatException(sink.toString(), _source, _failStart);
""";

  static const _methodFail = '''
    if (_failStart > _pos) {
      return false;
    }

    if (_failStart < _pos) {
      _failStart = _pos;
      _unterminated = null;
      {{CLEAR_FAILURES}}
    }   

    return true;
''';

  static const _methodGetChar = '''
    if (pos < _source.length) {
      _ch = _source.codeUnitAt(pos);
      if (_ch >= 0xD800) {
        return _getChar32(pos);
      }

      return _ch;
    }

    return _eof;
''';

  static const _methodGetChar32 = '''
    if (_ch >= 0xD800 && _ch <= 0xDBFF) {
      if (pos + 1 < _source.length) {
        final ch2 = _source.codeUnitAt(pos + 1);
        if (ch2 >= 0xDC00 && ch2 <= 0xDFFF) {
          _ch = ((_ch - 0xD800) << 10) + (ch2 - 0xDC00) + 0x10000;
        } else {
          throw FormatException('Unpaired high surrogate', _source, pos);
        }
      } else {
        throw FormatException('The source has been exhausted', _source, pos);
      }
    } else {
      if (_ch >= 0xDC00 && _ch <= 0xDFFF) {
        throw FormatException(
            'UTF-16 surrogate values are illegal in UTF-32', _source, pos);
      }
    }

    return _ch;
''';

  static const _methodMatchAny = '''
    if (_ch == _eof) {      
      ok = false;
      return null;
    }

    final ch = _ch;
    _pos += _ch <= 0xffff ? 1 : 2;
    _ch = _getChar(_pos);
    ok = true;
    return ch;
''';

  static const _methodMatchRanges = '''
    // Use binary search
    for (var i = 0; i < ranges.length; i += 2) {
      if (ranges[i] <= _ch) {
        if (ranges[i + 1] >= _ch) {
          final ch = _ch;
          _pos += _ch <= 0xffff ? 1 : 2;
          _ch = _getChar(_pos);
          ok = true;
          return ch;
        }
      } else {
        break;
      }
    }

    ok = false;    
    return null;
''';

  static const _methodNextChar = '''
    ok = true;
    _pos += _ch <= 0xffff ? 1 : 2;
    if (_pos < _source.length) {
      _ch = _source.codeUnitAt(_pos);
      if (_ch >= 0xD800) {
        _ch = _getChar32(_pos);
      }

      return value;
    }

    _ch = _eof;
    return value;
''';

  static const _methodReset = '''
    error = null;    
    _failStart = 0;
    {{CLEAR_FAILURES}}
    _length = _source.length;
    _pos = 0;
    _unterminated = null;
    _ch = _getChar(0);
    ok = false;
''';

  BitFlagGenerator? failures;

  final Grammar grammar;

  final ClassMembers members = ClassMembers();

  final String name;

  final ParserGeneratorOptions options;

  ParserClassGeneratorBase(this.name, this.grammar, this.options);

  void addMembers(ClassBuilder builder);

  Class generate() {
    return _generate();
  }

  List<ProductionRule> getTerminals() {
    final rules = grammar.rules
        .where((e) => e.kind == ProductionRuleKind.terminal)
        .toList();
    return rules;
  }

  void _addClassAttributes(ClassBuilder b) {
    b.name = name;
  }

  void _addField(
      ClassBuilder builder,
      FieldModifier modifier,
      String name,
      Field Function(ClassBuilder builder, FieldModifier modifier, String name)
          updates) {
    final field = updates(builder, modifier, name);
    final constant = modifier == FieldModifier.constant;
    members.addField(name, field, constant);
  }

  void _addFields(ClassBuilder builder) {
    _addField(
        builder,
        FieldModifier.constant,
        Members.eof,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.static = true;
              b.name = name;
              b.type = ref('int');
              b.assignment = literal(0x10ffff + 1).code;
            }));

    _addField(
        builder,
        FieldModifier.constant,
        Members.terminals,
        (b, modifier, name) => Field((b) {
              b.static = true;
              b.modifier = modifier;
              b.name = name;
              b.type = ref('List<String>');
              final terminals = getTerminals();
              terminals.sort((x, y) => x.terminalId.compareTo(y.terminalId));
              final names = terminals.map((e) => e.name);
              final values = names.map(literalString);
              b.assignment = literalList(values).code;
            }));

    _addField(
        builder,
        FieldModifier.var$,
        Members.error,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.name = name;
              b.type = ref('FormatException?');
            }));

    _addField(
        builder,
        FieldModifier.var$,
        Members.failStart,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.name = name;
              b.type = ref('int');
              b.assignment = literal(-1).code;
            }));

    _addField(
        builder,
        FieldModifier.var$,
        Members.ok,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.name = name;
              b.type = ref('bool');
              b.assignment = false$.code;
            }));

    _addField(
        builder,
        FieldModifier.var$,
        Members.ch,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.name = name;
              b.type = ref('int');
              b.assignment = literal(0).code;
            }));

    _addField(
        builder,
        FieldModifier.var$,
        Members.length,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.name = name;
              b.type = ref('int');
              b.assignment = literal(0).code;
            }));

    _addField(
        builder,
        FieldModifier.var$,
        Members.pos,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.name = name;
              b.type = ref('int');
              b.assignment = literal(0).code;
            }));

    _addField(
        builder,
        FieldModifier.var$,
        Members.source,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.name = name;
              b.type = ref('String');
              b.assignment = literalString('').code;
            }));

    _addField(
        builder,
        FieldModifier.var$,
        Members.unterminated,
        (b, modifier, name) => Field((b) {
              b.modifier = modifier;
              b.name = name;
              b.type = ref('String?');
            }));

    for (var name in failures!.variables) {
      _addField(
          builder,
          FieldModifier.var$,
          name,
          (b, modifier, name) => Field((b) {
                b.modifier = modifier;
                b.name = name;
                b.type = ref('int');
                b.assignment = literal(0).code;
              }));
    }
  }

  void _addMembersFromGrammar() {
    final members = grammar.members;
    if (members != null) {
      throw UnimplementedError(
          'The Dart code builder does not allow to add arbitrary code to classes');
    }
  }

  void _addMethod(
      ClassBuilder builder, String name, Reference returns, Code body,
      {bool inline = false,
      Map<String, Reference> parameters = const {},
      List<Reference> types = const []}) {
    final method = Method((b) {
      if (inline) {
        b.annotations
            .add(ref('pragma').call([literalString('vm:prefer-inline')]));
      }

      b.name = name;
      b.returns = returns;
      b.types.addAll(types);

      for (final key in parameters.keys) {
        b.requiredParameters.add(Parameter((b) {
          final type = parameters[key];
          b.name = key;
          b.type = type;
        }));
      }

      b.body = body;
    });

    members.addMethod(name, method);
  }

  void _addMethodParse(ClassBuilder builder) {
    final start = grammar.start!;
    final expression = start.expression;
    final returnType = start.returnType ?? expression.resultType;
    final nameGenerator = ProductionRuleNameGenerator();
    final returns = nullableType(returnType);
    final parameters = <String, Reference>{};
    parameters['source'] = ref('String');
    final code = <Code>[];
    code.add(Code(
        _methodParse.replaceAll('{{PARSE}}', nameGenerator.generate(start))));
    _addMethod(builder, 'parse', ref(returns), Block.of(code),
        parameters: parameters);
  }

  void _addMethods(ClassBuilder builder) {
    final clearFailures = failures!.generateClear().join('\n');
    String template;
    var returns = ref('void');
    var name = '_buildError';
    var body = Code(_methodBuildError);
    template = _methodBuildError;
    final addFlags = <String>[];
    for (final variable in failures!.variables) {
      addFlags.add('flags.add($variable);');
    }

    template = template.replaceAll('{{ADD_FAILURES}}', addFlags.join('\n'));
    body = Code(template);
    var parameters = <String, Reference>{};
    var types = <Reference>[];
    _addMethod(builder, name, returns, body);

    returns = ref('bool');
    name = Members.fail;
    template = _methodFail;
    template = template.replaceAll('{{CLEAR_FAILURES}}', clearFailures);
    body = Code(template);
    parameters = <String, Reference>{};
    parameters['name'] = ref('String');
    _addMethod(builder, name, returns, body,
        inline: true, parameters: parameters);

    returns = ref('int');
    name = '_getChar';
    parameters = <String, Reference>{};
    parameters['pos'] = ref('int');
    body = Code(_methodGetChar);
    _addMethod(builder, name, returns, body,
        inline: true, parameters: parameters);

    returns = ref('int');
    name = '_getChar32';
    parameters = <String, Reference>{};
    parameters['pos'] = ref('int');
    body = Code(_methodGetChar32);
    _addMethod(builder, name, returns, body,
        inline: true, parameters: parameters);

    returns = ref('int?');
    name = Members.matchAny;
    body = Code(_methodMatchAny);
    _addMethod(
      builder,
      name,
      returns,
      body,
      inline: true,
    );

    returns = ref('int?');
    name = Members.matchRanges;
    body = Code(_methodMatchRanges);
    parameters = {};
    parameters['ranges'] = ref('List<int>');
    _addMethod(builder, name, returns, body,
        inline: true, parameters: parameters);

    returns = ref('T');
    name = Members.nextChar;
    body = Code(_methodNextChar);
    parameters = {};
    parameters['value'] = ref('T');
    types = [];
    types.add(ref('T'));
    _addMethod(builder, name, returns, body,
        inline: true, parameters: parameters, types: types);

    returns = ref('void');
    name = '_reset';
    template = _methodReset;
    template = template.replaceAll('{{CLEAR_FAILURES}}', clearFailures);
    body = Code(template);
    _addMethod(builder, name, returns, body);
  }

  Class _generate() {
    return Class((b) {
      _initialize();
      _addClassAttributes(b);
      _addFields(b);
      _addMethodParse(b);
      _addMethods(b);
      _addMembersFromGrammar();
      addMembers(b);
      _generateFields(b);
      _generateMethods(b);
    });
  }

  void _generateFields(ClassBuilder builder) {
    void generate1(Iterable<String> names, Map<String, Field> fields) {
      final list = names.toList();
      list.sort();
      for (final name in list) {
        final field = fields[name]!;
        builder.fields.add(field);
      }
    }

    void generate0(Map<String, Field> members) {
      final public = members.keys.where((e) => !e.startsWith('_'));
      generate1(public, members);
      final private = members.keys.where((e) => e.startsWith('_'));
      generate1(private, members);
    }

    generate0(members.constants);
    generate0(members.fields);
  }

  void _generateMethods(ClassBuilder builder) {
    final methods = members.methods;
    final public = methods.keys.where((e) => !e.startsWith('_')).toList();
    public.sort();
    for (final name in public) {
      final method = methods[name]!;
      builder.methods.add(method);
    }

    final private = methods.keys.where((e) => e.startsWith('_')).toList();
    private.sort();
    for (final name in private) {
      final method = methods[name]!;
      builder.methods.add(method);
    }
  }

  void _initialize() {
    final terminals = getTerminals();
    failures = BitFlagGenerator(terminals.length, Members.failures);
  }
}
