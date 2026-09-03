import 'package:flutter_test/flutter_test.dart';
import 'package:loop/data/local/mapping/enum_codec.dart';
import 'package:loop/domain/loop/loop_state.dart';

void main() {
  group('enum codec', () {
    test('stores by name, not by ordinal', () {
      expect(encodeEnum(LoopState.waiting), 'waiting');
    });

    test('every LoopState value round-trips through its name', () {
      for (final LoopState state in LoopState.values) {
        final String stored = encodeEnum(state);
        expect(decodeEnum(LoopState.values, stored), state);
      }
    });

    test('reordering the enum would not change a stored name', () {
      // The point of the whole file: encodeEnum never touches `.index`, so a
      // case inserted before `waiting` in the declaration tomorrow cannot
      // silently turn today's stored "waiting" rows into a different state.
      expect(encodeEnum(LoopState.waiting), isNot(LoopState.waiting.index));
      expect(encodeEnum(LoopState.waiting), 'waiting');
    });

    test(
        'an unrecognised stored value fails loudly rather than silently '
        'reinterpreting', () {
      expect(
        () => decodeEnum(LoopState.values, 'atRisk'),
        throwsArgumentError,
      );
    });

    test('an empty stored value fails loudly', () {
      expect(() => decodeEnum(LoopState.values, ''), throwsArgumentError);
    });
  });
}
