part of '../../matcher_generators.dart';

class PostfixAnyCharacterGenerator
    extends MatcherGenerator<PostfixAnyCharacterMatcher> {
  PostfixAnyCharacterGenerator(PostfixAnyCharacterMatcher matcher)
      : super(matcher) {
    generate = _generate;
  }

  void _generate(CodeBlock block, MatcherGeneratorAccept accept) {
    // TODO
    throw UnimplementedError();
  }
}
