// Generated by 'peg2'
// https://pub.dev/packages/peg2

void main() {
  final parser = ExampleParser();
  final result = parser.parse(_text);
  if (parser.error != null) {
    throw parser.error;
  }

  print(result);
}

final _text = '''
{"rocket": "🚀 flies to the stars"}
''';

class ExampleParser {
  static const _eof = 0x110000;
  
  FormatException error;
  
  int _c;
  
  int _error;
  
  List<String> _expected;
  
  int _failure;
  
  List<int> _input;
  
  List<bool> _memoizable;
  
  List<List<_Memo>> _memos;
  
  var _mresult;
  
  int _pos;
  
  bool _predicate;
  
  dynamic _result;
  
  bool _success;
  
  String _text;
  
  List<int> _trackCid;
  
  List<int> _trackPos;
  
  dynamic parse(String text) {
    if (text == null) {
      throw ArgumentError.notNull('text');
    }
    _text = text;
    _input = _toRunes(text);
    _reset();  
    final result = _e0(0, true);
    _buildError();
    _expected = null;
    _input = null;
    return result;
  }
  
  void _buildError() {
    if (_success) {
      error = null;
      return;
    }
  
    String escape(int c) {
      switch (c) {
        case 10:
          return r'\n';
        case 13:
          return r'\r';
        case 09:
          return r'\t';
        case _eof:
          return 'end of file';
      }
      return String.fromCharCode(c);
    }
  
    String getc(int position) {
      if (position < _text.length) {
        return "'${escape(_input[position])}'";
      }
      return 'end of file';
    }
  
    String report(String message, String source, int start) {
      if (start < 0 || start > source.length) {
        start = null;
      }
  
      final sb = StringBuffer();
      sb.write(message);
      var line = 0;
      var col = 0;
      var lineStart = 0;
      var started = false;
      if (start != null) {
        for (var i = 0; i < source.length; i++) {
          final c = source.codeUnitAt(i);
          if (!started) {
            started = true;
            lineStart = i;
            line++;
            col = 1;
          } else {
            col++;
          }
          if (c == 10) {
            started = false;
          }
          if (start == i) {
            break;
          }
        }
      }
  
      if (start == null) {
        sb.writeln('.');
      } else if (line == 0 || start == source.length) {
        sb.write(' (at offset ');
        sb.write(start);
        sb.writeln('):');
      } else {
        sb.write(' (at line ');
        sb.write(line);
        sb.write(', column ');
        sb.write(col);
        sb.writeln('):');
      }
  
      List<int> escape(int c) {
        switch (c) {
          case 9:
            return [92, 116];
          case 10:
            return [92, 110];
          case 13:
            return [92, 114];
          default:
            return [c];
        }
      }
  
      const max = 70;
      if (start != null) {
        final c1 = <int>[];
        final c2 = <int>[];
        final half = max ~/ 2;
        var cr = false;
        for (var i = start; i >= lineStart && c1.length < half; i--) {
          if (i == source.length) {
            c2.insert(0, 94);
          } else {
            final c = source.codeUnitAt(i);
            final escaped = escape(c);
            c1.insertAll(0, escaped);
            if (c == 10) {
              cr = true;
            }
  
            final r = i == start ? 94 : 32;
            for (var k = 0; k < escaped.length; k++) {
              c2.insert(0, r);
            }
          }
        }
  
        for (var i = start + 1;
            i < source.length && c1.length < max && !cr;
            i++) {
          final c = source.codeUnitAt(i);
          final escaped = escape(c);
          c1.addAll(escaped);
          if (c == 10) {
            break;
          }
        }
  
        final text1 = String.fromCharCodes(c1);
        final text2 = String.fromCharCodes(c2);
        sb.writeln(text1);
        sb.writeln(text2);
      }
  
      return sb.toString();
    }
  
    final temp = _expected.toList();
    temp.sort((e1, e2) => e1.compareTo(e2));
    final expected = temp.toSet();
    final hasMalformed = false;
    if (expected.isNotEmpty) {
      if (!hasMalformed) {
        final sb = StringBuffer();
        sb.write('Expected ');
        sb.write(expected.join(', '));
        sb.write(' but found ');
        sb.write(getc(_error));
        final title = sb.toString();
        final message = report(title, _text, _error);
        error = FormatException(message);
      } else {
        final reason = _error == _text.length ? 'Unterminated' : 'Malformed';
        final sb = StringBuffer();
        sb.write(reason);
        sb.write(' ');
        sb.write(expected.join(', '));
        final title = sb.toString();
        final message = report(title, _text, _error);
        error = FormatException(message);
      }
    } else {
      final sb = StringBuffer();
      sb.write('Unexpected character ');
      sb.write(getc(_error));
      final title = sb.toString();
      final message = report(title, _text, _error);
      error = FormatException(message);
    }
  }
  
  void _fail(List<String> expected) {
    if (_error < _failure) {
      _error = _failure;
      _expected = [];
    }
    if (_error == _failure) {
      _expected.addAll(expected);
    }
  }
  
  int _matchRanges(List<int> ranges) {
    int result;
    _success = false;
    for (var i = 0; i < ranges.length; i += 2) {
      if (ranges[i] <= _c) {
        if (ranges[i + 1] >= _c) {
          result = _c;
          _c = _input[_pos += _c <= 0xffff ? 1 : 2];
          _success = true;
          break;
        }
      } else {
        break;
      }
    }
  
    if (!_success) {
      _failure = _pos;
    }
  
    return result;
  }
  
  String _matchString(String text) {
    String result;
    final length = text.length;
    final rest = _text.length - _pos;
    final count = length > rest ? rest : length;
    var pos = _pos;
    var i = 0;
    for (; i < count; i++, pos++) {
      if (text.codeUnitAt(i) != _text.codeUnitAt(pos)) {
        break;
      }
    }
  
    if (_success = i == length) {
      _c = _input[_pos += length];    
      result = text;
    } else {    
      _failure = _pos + i;
    }
  
    return result;
  }
  
  bool _memoized(int id, int cid) {
    final memos = _memos[_pos];
    if (memos != null) {
      for (var i = 0; i < memos.length; i++) {
        final memo = memos[i];
        if (memo.id == id) {        
          _pos = memo.pos;
          _mresult = memo.result;
          _success = memo.success;  
          _c = _input[_pos];
          return true;
        }
      }
    }  
  
    if (_memoizable[cid] != null) {
      return false;
    }
  
    final lastCid = _trackCid[id];
    final lastPos = _trackPos[id];
    _trackCid[id] = cid;
    _trackPos[id] = _pos;
    if (lastCid == null) {    
      return false;
    }
  
    if (lastPos == _pos) {
      if (lastCid != cid) {
        _memoizable[lastCid] = true;
        _memoizable[cid] = false;
      }
    }
    
    return false;
  }
  
  void _memoize(int id, int pos, result) {
    var memos = _memos[pos];
    if (memos == null) {
      memos = [];
      _memos[pos] = memos;
    }
  
    final memo = _Memo(
      id: id,
      pos: _pos,
      result: result,
      success: _success,
    );
  
    memos.add(memo);
  }
  
  void _reset() {
    _c = _input[0];
    _error = 0;
    _expected = [];
    _failure = -1;
    _memoizable = [];
    _memoizable.length = 183;
    _memos = [];
    _memos.length = _input.length + 1;
    _pos = 0;
    _predicate = false;
    _success = false;
    _trackCid = [];
    _trackCid.length = 183;
    _trackPos = [];
    _trackPos.length = 183;
  }
  
  List<int> _toRunes(String source) {
    final length = source.length;
    final result = List<int>(length + 1);
    for (var pos = 0; pos < length;) {
      int c;
      final start = pos;
      final leading = source.codeUnitAt(pos++);
      if ((leading & 0xFC00) == 0xD800 && pos < length) {
        final trailing = source.codeUnitAt(pos);
        if ((trailing & 0xFC00) == 0xDC00) {
          c = 0x10000 + ((leading & 0x3FF) << 10) + (trailing & 0x3FF);
          pos++;
        } else {
          c = leading;
        }
      } else {
        c = leading;
      }
  
      result[start] = c;
    }
  
    result[length] = 0x110000;
    return result;
  }
  
  void _foo() {
    if (_state == 0) {
      _success = true;
      _r0.f1 = _r0.f0;
    }
    if (_state == 1) {
    }
    if (_state == 2) {
      _success = true;
      _r2.f1 = _r2.f0;
    }
    if (_state == 3) {
      _r3.f1 = [];
      _r3.v0 = true;
      _state = 4;
      break;
    }
    if (_state == 4) {
      if (_success) {
        if (_r3.v0) {
          _r3.f1 = null;
        } else {
          _state = 5;
          break;
        }
      }
      _r3.v0 = false;
      _r3.f1.add(_r3.f0);
      _state = 4;
      break;
    }
    if (_state == 5) {
    }
    if (_state == 6) {
      _success = true;
      _r4.f1 = _r4.f0;
    }
    if (_state == 7) {
      _r5.f1 = [];
      _r5.v0 = true;
      _state = 8;
      break;
    }
    if (_state == 8) {
      if (_success) {
        if (_r5.v0) {
          _r5.f1 = null;
        } else {
          _state = 9;
          break;
        }
      }
      _r5.v0 = false;
      _r5.f1.add(_r5.f0);
      _state = 8;
      break;
    }
    if (_state == 9) {
    }
    if (_state == 10) {
    }
    if (_state == 11) {
      _r7.v0 = _c;
      _r7.v1 = _pos;
      _r7.v2 = _productive;
      _r7.v2 = false;
      _success = !_success;
      _c = _r7.v0;
      _pos = _r7.v1;
      _productive = _r7.v2;
      _r7.f0 = null;
    }
    if (_state == 12) {
    }
    if (_state == 13) {
    }
    if (_state == 14) {
    }
    if (_state == 15) {
    }
    if (_state == 16) {
      _r12.f1 = [];
      _r12.v0 = true;
      _state = 17;
      break;
    }
    if (_state == 17) {
      if (_success) {
        if (_r12.v0) {
          _r12.f1 = null;
        } else {
          _state = 18;
          break;
        }
      }
      _r12.v0 = false;
      _r12.f1.add(_r12.f0);
      _state = 17;
      break;
    }
    if (_state == 18) {
    }
    if (_state == 19) {
      _success = true;
      _r13.f1 = _r13.f0;
      _r13.f3 = [];
      _r13.v0 = true;
      _state = 20;
      break;
    }
    if (_state == 20) {
      if (_success) {
        if (_r13.v0) {
          _r13.f3 = null;
        } else {
          _state = 21;
          break;
        }
      }
      _r13.v0 = false;
      _r13.f3.add(_r13.f2);
      _state = 20;
      break;
    }
    if (_state == 21) {
      _success = true;
      _r13.f5 = _r13.f4;
      _success = true;
      _r13.f7 = _r13.f6;
      _success = true;
      _r13.f9 = _r13.f8;
    }
    if (_state == 22) {
    }
    if (_state == 23) {
    }
    if (_state == 24) {
    }
    if (_state == 25) {
    }
    if (_state == 26) {
    }
    if (_state == 27) {
    }
    if (_state == 28) {
    }
    if (_state == 29) {
    }
    if (_state == 30) {
    }
    if (_state == 31) {
    }
    if (_state == 32) {
    }
    if (_state == 33) {
      _r25.f1 = [];
      _r25.v0 = true;
      _state = 34;
      break;
    }
    if (_state == 34) {
      if (_success) {
        if (_r25.v0) {
          _r25.f1 = null;
        } else {
          _state = 35;
          break;
        }
      }
      _r25.v0 = false;
      _r25.f1.add(_r25.f0);
      _state = 34;
      break;
    }
    if (_state == 35) {
    }
  }
  
}

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

// ignore_for_file: unused_element
// ignore_for_file: unused_field