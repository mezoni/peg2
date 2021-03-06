// Generated by 'peg2'
// https://pub.dev/packages/peg2

void main() {
  final text = '''
{"rocket": "🚀 flies to the stars"}
''';

  final parser = ExampleParser();
  final result = parser.parse(text);
  if (!parser.ok) {
    throw parser.error!;
  }

  print(result);
}

class ExampleParser {
  static const int _eof = 1114112;

  static const List<String> _terminals = [
    '\'end of file\'',
    '\'false\'',
    '\'leading spaces\'',
    '\'null\'',
    '\'true\'',
    '\'string\'',
    '\'number\'',
    '\'{\'',
    '\'}\'',
    '\'[\'',
    '\']\'',
    '\',\'',
    '\':\''
  ];

  FormatException? error;

  bool ok = false;

  int _ch = 0;

  int _failStart = -1;

  int _failures0 = 0;

  int _length = 0;

  int _pos = 0;

  String _source = '';

  String? _unterminated;

  dynamic parse(String source) {
    _source = source;
    _reset();
    final result = _parseJson();
    if (!ok) {
      _buildError();
    }

    return result;
  }

  void _buildError() {
    final sink = StringBuffer();
    sink.write('Syntax error, ');
    if (_unterminated != null) {
      sink.write('unterminated ');
      sink.write(_unterminated);
    } else {
      final names = <String>[];
      final flags = <int>[];
      flags.add(_failures0);
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
  }

  @pragma('vm:prefer-inline')
  bool _fail(String name) {
    if (_failStart > _pos) {
      return false;
    }

    if (_failStart < _pos) {
      _failStart = _pos;
      _unterminated = null;
      _failures0 = 0;
    }

    return true;
  }

  @pragma('vm:prefer-inline')
  int _getChar(int pos) {
    if (pos < _source.length) {
      _ch = _source.codeUnitAt(pos);
      if (_ch >= 0xD800) {
        return _getChar32(pos);
      }

      return _ch;
    }

    return _eof;
  }

  @pragma('vm:prefer-inline')
  int _getChar32(int pos) {
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
  }

  @pragma('vm:prefer-inline')
  int? _matchAny() {
    if (_ch == _eof) {
      ok = false;
      return null;
    }

    final ch = _ch;
    _pos += _ch <= 0xffff ? 1 : 2;
    _ch = _getChar(_pos);
    ok = true;
    return ch;
  }

  @pragma('vm:prefer-inline')
  int? _matchRanges(List<int> ranges) {
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
  }

  @pragma('vm:prefer-inline')
  T _nextChar<T>(T value) {
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
  }

  @pragma('vm:prefer-inline')
  int? _parse$$char() {
    int? $0;
    final $1 = _ch;
    final $2 = _pos;
    ok = false;
    if (_ch == 92) {
      _nextChar(_ch);
    }
    if (ok) {
      $0 = _parse$$escaped();
      if (ok) {
        final r = $0!;
        $0 = r;
      }
    }
    if (ok) {
      return $0;
    }
    _ch = $1;
    _pos = $2;
    $0 = _parse$$unescaped();

    if (ok) {
      return $0;
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  int? _parse$$escaped() {
    int? $0;
    final $1 = _ch;
    final $2 = _pos;
    ok = false;
    if (_ch == 34) {
      $0 = _nextChar(_ch);
    }

    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch == 92) {
      $0 = _nextChar(_ch);
    }

    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch == 47) {
      $0 = _nextChar(_ch);
    }

    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch == 98) {
      _nextChar(_ch);
    }
    if (ok) {
      int? $$;
      $$ = 0x8;
      $0 = $$;
    }
    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch == 102) {
      _nextChar(_ch);
    }
    if (ok) {
      int? $$;
      $$ = 0xC;
      $0 = $$;
    }
    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch == 110) {
      _nextChar(_ch);
    }
    if (ok) {
      int? $$;
      $$ = 0xA;
      $0 = $$;
    }
    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch == 114) {
      _nextChar(_ch);
    }
    if (ok) {
      int? $$;
      $$ = 0xD;
      $0 = $$;
    }
    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch == 116) {
      _nextChar(_ch);
    }
    if (ok) {
      int? $$;
      $$ = 0x9;
      $0 = $$;
    }
    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch == 117) {
      _nextChar(_ch);
    }
    if (ok) {
      $0 = _parse$$hexdig4();
      if (ok) {
        final r = $0!;
        $0 = r;
      }
    }
    if (ok) {
      return $0;
    }
    _ch = $1;
    _pos = $2;
    return $0;
  }

  int? _parse$$hexdig() {
    int? $0;
    int? $1;
    ok = false;
    if (_ch >= 97 && _ch <= 102) {
      $1 = _nextChar(_ch);
    }
    if (ok) {
      final v = $1!;
      int? $$;
      $$ = v - 97;
      $0 = $$;
    }
    if (ok) {
      return $0;
    }
    int? $2;
    ok = false;
    if (_ch >= 65 && _ch <= 70) {
      $2 = _nextChar(_ch);
    }
    if (ok) {
      final v = $2!;
      int? $$;
      $$ = v - 65;
      $0 = $$;
    }
    if (ok) {
      return $0;
    }
    int? $3;
    ok = false;
    if (_ch >= 48 && _ch <= 57) {
      $3 = _nextChar(_ch);
    }
    if (ok) {
      final v = $3!;
      int? $$;
      $$ = v - 48;
      $0 = $$;
    }
    if (ok) {
      return $0;
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  int? _parse$$hexdig4() {
    int? $0;
    final $1 = _ch;
    final $2 = _pos;
    final $3 = _parse$$hexdig();
    if (ok) {
      final $4 = _parse$$hexdig();
      if (ok) {
        final $5 = _parse$$hexdig();
        if (ok) {
          final $6 = _parse$$hexdig();
          if (ok) {
            final a = $3!;
            final b = $4!;
            final c = $5!;
            final d = $6!;
            int? $$;
            $$ = a * 0xfff + b * 0xff + c * 0xf + d;
            $0 = $$;
          }
        }
      }
    }
    if (!ok) {
      _ch = $1;
      _pos = $2;
    }
    return $0;
  }

  List<int>? _parse$$spacing() {
    do {
      ok = false;
      if (_ch >= 9 && _ch <= 10 || _ch == 13 || _ch == 32) {
        _nextChar(_ch);
      }
    } while (ok);
    ok = true;

    return null;
  }

  @pragma('vm:prefer-inline')
  int? _parse$$unescaped() {
    int? $0;
    ok = false;
    if (_ch >= 32 && _ch <= 33) {
      $0 = _nextChar(_ch);
    }

    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch >= 35 && _ch <= 91) {
      $0 = _nextChar(_ch);
    }

    if (ok) {
      return $0;
    }
    ok = false;
    if (_ch >= 93 && _ch <= 1114111) {
      $0 = _nextChar(_ch);
    }

    if (ok) {
      return $0;
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  List? _parseArray() {
    List? $0;
    final $1 = _ch;
    final $2 = _pos;
    _parse_$LeftSquareBracket();
    if (ok) {
      final $3 = _parseValues();
      ok = true;
      _parse_$RightSquareBracket();
      if (ok) {
        final v = $3;
        List? $$;
        $$ = v ?? [];
        $0 = $$;
      }
    }
    if (!ok) {
      _ch = $1;
      _pos = $2;
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  dynamic _parseJson() {
    dynamic $0;
    final $1 = _ch;
    final $2 = _pos;
    _parse_leading_spaces();
    $0 = _parseValue();
    if (ok) {
      _parse_end_of_file();
      if (ok) {
        final v = $0;
        $0 = v;
      }
    }
    if (!ok) {
      _ch = $1;
      _pos = $2;
    }
    return $0;
  }

  MapEntry<String, dynamic>? _parseMember() {
    MapEntry<String, dynamic>? $0;
    final $1 = _ch;
    final $2 = _pos;
    final $3 = _parse_string();
    if (ok) {
      _parse_$Colon();
      if (ok) {
        final $4 = _parseValue();
        if (ok) {
          final k = $3!;
          final v = $4;
          MapEntry<String, dynamic>? $$;
          $$ = MapEntry(k, v);
          $0 = $$;
        }
      }
    }
    if (!ok) {
      _ch = $1;
      _pos = $2;
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  List<MapEntry<String, dynamic>>? _parseMembers() {
    List<MapEntry<String, dynamic>>? $0;
    final $1 = _parseMember();
    if (ok) {
      List<MapEntry<String, dynamic>>? $2;
      final $3 = <MapEntry<String, dynamic>>[];
      while (true) {
        MapEntry<String, dynamic>? $4;
        final $5 = _ch;
        final $6 = _pos;
        _parse_$Comma();
        if (ok) {
          $4 = _parseMember();
          if (ok) {
            final m = $4!;
            $4 = m;
          }
        }
        if (!ok) {
          _ch = $5;
          _pos = $6;
          break;
        }
        $3.add($4!);
      }
      if (ok = true) {
        $2 = $3;
      }
      final m = $1!;
      final n = $2!;
      List<MapEntry<String, dynamic>>? $$;
      $$ = [m, ...n];
      $0 = $$;
    }

    return $0;
  }

  @pragma('vm:prefer-inline')
  Map<String, dynamic>? _parseObject() {
    Map<String, dynamic>? $0;
    final $1 = _ch;
    final $2 = _pos;
    _parse_$LeftBrace();
    if (ok) {
      final $3 = _parseMembers();
      ok = true;
      _parse_$RightBrace();
      if (ok) {
        final m = $3;
        Map<String, dynamic>? $$;
        $$ = <String, dynamic>{}..addEntries(m ?? []);
        $0 = $$;
      }
    }
    if (!ok) {
      _ch = $1;
      _pos = $2;
    }
    return $0;
  }

  dynamic _parseValue() {
    dynamic $0;
    $0 = _parseArray();
    if (ok) {
      final Array = $0!;
      $0 = Array;
    }
    if (ok) {
      return $0;
    }
    $0 = _parse_false();

    if (ok) {
      return $0;
    }
    $0 = _parse_null();

    if (ok) {
      return $0;
    }
    $0 = _parse_true();

    if (ok) {
      return $0;
    }
    $0 = _parseObject();
    if (ok) {
      final Object = $0!;
      $0 = Object;
    }
    if (ok) {
      return $0;
    }
    $0 = _parse_number();

    if (ok) {
      return $0;
    }
    $0 = _parse_string();

    if (ok) {
      return $0;
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  List? _parseValues() {
    List? $0;
    final $1 = _parseValue();
    if (ok) {
      List? $2;
      final $3 = <dynamic>[];
      while (true) {
        dynamic $4;
        final $5 = _ch;
        final $6 = _pos;
        _parse_$Comma();
        if (ok) {
          $4 = _parseValue();
          if (ok) {
            final v = $4;
            $4 = v;
          }
        }
        if (!ok) {
          _ch = $5;
          _pos = $6;
          break;
        }
        $3.add($4);
      }
      if (ok = true) {
        $2 = $3;
      }
      final v = $1;
      final n = $2!;
      List? $$;
      $$ = [v, ...n];
      $0 = $$;
    }

    return $0;
  }

  @pragma('vm:prefer-inline')
  String? _parse_$Colon() {
    ok = false;
    if (_ch == 58) {
      _nextChar(':');
    }
    if (ok) {
      _parse$$spacing();
    }
    if (!ok) {
      if (_fail('\':\'')) {
        _failures0 |= 0x1000;
      }
    }
    return null;
  }

  String? _parse_$Comma() {
    ok = false;
    if (_ch == 44) {
      _nextChar(',');
    }
    if (ok) {
      _parse$$spacing();
    }
    if (!ok) {
      if (_fail('\',\'')) {
        _failures0 |= 0x800;
      }
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  String? _parse_$LeftBrace() {
    ok = false;
    if (_ch == 123) {
      _nextChar('{');
    }
    if (ok) {
      _parse$$spacing();
    }
    if (!ok) {
      if (_fail('\'{\'')) {
        _failures0 |= 0x80;
      }
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  String? _parse_$LeftSquareBracket() {
    ok = false;
    if (_ch == 91) {
      _nextChar('[');
    }
    if (ok) {
      _parse$$spacing();
    }
    if (!ok) {
      if (_fail('\'[\'')) {
        _failures0 |= 0x200;
      }
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  String? _parse_$RightBrace() {
    ok = false;
    if (_ch == 125) {
      _nextChar('}');
    }
    if (ok) {
      _parse$$spacing();
    }
    if (!ok) {
      if (_fail('\'}\'')) {
        _failures0 |= 0x100;
      }
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  String? _parse_$RightSquareBracket() {
    ok = false;
    if (_ch == 93) {
      _nextChar(']');
    }
    if (ok) {
      _parse$$spacing();
    }
    if (!ok) {
      if (_fail('\']\'')) {
        _failures0 |= 0x400;
      }
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  dynamic _parse_end_of_file() {
    ok = _ch == 1114112;
    if (!ok) {
      if (_fail('\'end of file\'')) {
        _failures0 |= 0x1;
      }
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  dynamic _parse_false() {
    dynamic $0;
    ok = _source.startsWith('false', _pos);
    if (ok) {
      _ch = _getChar(_pos += 5);
    }
    if (ok) {
      _parse$$spacing();
      dynamic $$;
      $$ = false;
      $0 = $$;
    }
    if (!ok) {
      if (_fail('\'false\'')) {
        _failures0 |= 0x2;
      }
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  List<int>? _parse_leading_spaces() {
    _parse$$spacing();

    return null;
  }

  @pragma('vm:prefer-inline')
  dynamic _parse_null() {
    dynamic $0;
    ok = _source.startsWith('null', _pos);
    if (ok) {
      _ch = _getChar(_pos += 4);
    }
    if (ok) {
      _parse$$spacing();
      dynamic $$;
      $$ = null;
      $0 = $$;
    }
    if (!ok) {
      if (_fail('\'null\'')) {
        _failures0 |= 0x8;
      }
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  num? _parse_number() {
    num? $0;
    String? $1;
    final $2 = _pos;
    final $3 = _ch;
    ok = false;
    if (_ch == 45) {
      _nextChar(_ch);
    }
    ok = true;
    while (true) {
      ok = false;
      if (_ch == 48) {
        _nextChar(_ch);
      }
      if (ok) {
        break;
      }
      ok = false;
      if (_ch >= 49 && _ch <= 57) {
        _nextChar(_ch);
      }
      if (ok) {
        do {
          ok = false;
          if (_ch >= 48 && _ch <= 57) {
            _nextChar(_ch);
          }
        } while (ok);
        ok = true;
      }
      if (ok) {
        break;
      }
      break;
    }
    if (ok) {
      final $4 = _ch;
      final $5 = _pos;
      ok = false;
      if (_ch == 46) {
        _nextChar(_ch);
      }
      if (ok) {
        var $6 = 0;
        do {
          ok = false;
          if (_ch >= 48 && _ch <= 57) {
            _nextChar(_ch);
          }
          $6++;
        } while (ok);
        ok = $6 != 1;
      }
      if (!ok) {
        _ch = $4;
        _pos = $5;
      }
      ok = true;
      final $7 = _ch;
      final $8 = _pos;
      ok = false;
      if (_ch == 69 || _ch == 101) {
        _nextChar(_ch);
      }
      if (ok) {
        ok = false;
        if (_ch == 43 || _ch == 45) {
          _nextChar(_ch);
        }
        ok = true;
        var $9 = 0;
        do {
          ok = false;
          if (_ch >= 48 && _ch <= 57) {
            _nextChar(_ch);
          }
          $9++;
        } while (ok);
        ok = $9 != 1;
      }
      if (!ok) {
        _ch = $7;
        _pos = $8;
      }
      ok = true;
    }
    if (!ok) {
      _ch = $3;
    }
    if (ok) {
      $1 = _source.substring($2, _pos);
    }
    if (ok) {
      _parse$$spacing();
      final n = $1!;
      num? $$;
      $$ = num.parse(n);
      $0 = $$;
    }
    if (!ok) {
      if (_fail('\'number\'')) {
        _failures0 |= 0x40;
      }
    }
    return $0;
  }

  String? _parse_string() {
    String? $0;
    final $1 = _ch;
    final $2 = _pos;
    ok = false;
    if (_ch == 34) {
      _nextChar('"');
    }
    if (ok) {
      List<int>? $3;
      final $4 = <int>[];
      while (true) {
        final $5 = _parse$$char();
        if (!ok) {
          break;
        }
        $4.add($5!);
      }
      if (ok = true) {
        $3 = $4;
      }
      ok = false;
      if (_ch == 34) {
        _nextChar('"');
      }
      if (ok) {
        _parse$$spacing();
        final c = $3!;
        String? $$;
        $$ = String.fromCharCodes(c);
        $0 = $$;
      }
    }
    if (!ok) {
      _ch = $1;
      _pos = $2;
      if (_fail('\'string\'')) {
        _failures0 |= 0x20;
      }
    }
    return $0;
  }

  @pragma('vm:prefer-inline')
  dynamic _parse_true() {
    dynamic $0;
    ok = _source.startsWith('true', _pos);
    if (ok) {
      _ch = _getChar(_pos += 4);
    }
    if (ok) {
      _parse$$spacing();
      dynamic $$;
      $$ = true;
      $0 = $$;
    }
    if (!ok) {
      if (_fail('\'true\'')) {
        _failures0 |= 0x10;
      }
    }
    return $0;
  }

  void _reset() {
    error = null;
    _failStart = 0;
    _failures0 = 0;
    _length = _source.length;
    _pos = 0;
    _unterminated = null;
    _ch = _getChar(0);
    ok = false;
  }
}
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unused_element
