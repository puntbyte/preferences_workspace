import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:test/test.dart';

void main() {
  group('MethodNamer.resolve', () {
    group('{{name}} token', () {
      test('substitutes the raw camelCase field name', () {
        expect(MethodNamer.resolve('{{name}}', 'username'), 'username');
        expect(MethodNamer.resolve('{{name}}Stream', 'username'), 'usernameStream');
        expect(MethodNamer.resolve('{{name}}Async', 'isFirstLaunch'), 'isFirstLaunchAsync');
        expect(MethodNamer.resolve('watch{{name}}', 'theme'), 'watchtheme');
      });
    });

    group('{{Name}} token', () {
      test('substitutes the field name with first letter capitalised', () {
        expect(MethodNamer.resolve('set{{Name}}', 'username'), 'setUsername');
        expect(MethodNamer.resolve('set{{Name}}', 'isFirstLaunch'), 'setIsFirstLaunch');
        expect(MethodNamer.resolve('remove{{Name}}', 'accentColor'), 'removeAccentColor');
        expect(MethodNamer.resolve('get{{Name}}Async', 'themeMode'), 'getThemeModeAsync');
      });

      test('capitalises a single-character field name correctly', () {
        expect(MethodNamer.resolve('set{{Name}}', 'x'), 'setX');
      });
    });

    group('mixed tokens', () {
      test('supports both tokens in a single template', () {
        // Unusual but valid — both tokens present.
        expect(
          MethodNamer.resolve('{{name}}_or_{{Name}}', 'theme'),
          'theme_or_Theme',
        );
      });

      test('substitutes multiple occurrences of the same token', () {
        expect(
          MethodNamer.resolve('{{Name}}{{Name}}', 'foo'),
          'FooFoo',
        );
      });
    });

    group('preset-like patterns', () {
      test('.reactive() getter pattern', () {
        expect(MethodNamer.resolve('{{name}}', 'accentColor'), 'accentColor');
      });

      test('.reactive() setter pattern', () {
        expect(MethodNamer.resolve('set{{Name}}', 'accentColor'), 'setAccentColor');
      });

      test('.reactive() stream pattern', () {
        expect(MethodNamer.resolve('{{name}}Stream', 'accentColor'), 'accentColorStream');
      });

      test('.dictionary() getter pattern', () {
        expect(MethodNamer.resolve('get{{Name}}', 'launchCount'), 'getLaunchCount');
      });

      test('.syncOnly() setter pattern', () {
        expect(MethodNamer.resolve('put{{Name}}', 'launchCount'), 'putLaunchCount');
      });

      test('.syncOnly() remover pattern', () {
        expect(MethodNamer.resolve('delete{{Name}}', 'launchCount'), 'deleteLaunchCount');
      });

      test('.exhaustive() sync getter pattern', () {
        expect(
          MethodNamer.resolve('get{{Name}}Sync', 'isFirstLaunch'),
          'getIsFirstLaunchSync',
        );
      });

      test('.exhaustive() async setter pattern', () {
        expect(
          MethodNamer.resolve('set{{Name}}Async', 'isFirstLaunch'),
          'setIsFirstLaunchAsync',
        );
      });

      test('.exhaustive() stream pattern', () {
        expect(
          MethodNamer.resolve('watch{{Name}}Stream', 'isFirstLaunch'),
          'watchIsFirstLaunchStream',
        );
      });

      test('custom stream prefix and suffix from @PrefEntry', () {
        // @PrefEntry(streamer: 'watch{{Name}}Changes')
        expect(
          MethodNamer.resolve('watch{{Name}}Changes', 'authToken'),
          'watchAuthTokenChanges',
        );
      });
    });

    group('edge cases', () {
      test('empty entry name produces empty substitution', () {
        expect(MethodNamer.resolve('set{{Name}}', ''), 'set');
        expect(MethodNamer.resolve('{{name}}Stream', ''), 'Stream');
      });

      test('template with no tokens passes through unchanged', () {
        // This should be caught by validation before it reaches resolve(),
        // but the function itself should not throw.
        expect(MethodNamer.resolve('hardCodedName', 'username'), 'hardCodedName');
      });
    });
  });

  group('MethodNamer.hasToken', () {
    test('returns true for templates containing {{name}}', () {
      expect(MethodNamer.hasToken('{{name}}'), isTrue);
      expect(MethodNamer.hasToken('{{name}}Stream'), isTrue);
      expect(MethodNamer.hasToken('get{{name}}'), isTrue);
    });

    test('returns true for templates containing {{Name}}', () {
      expect(MethodNamer.hasToken('{{Name}}'), isTrue);
      expect(MethodNamer.hasToken('set{{Name}}'), isTrue);
      expect(MethodNamer.hasToken('get{{Name}}Async'), isTrue);
    });

    test('returns true when both tokens are present', () {
      expect(MethodNamer.hasToken('{{name}}_{{Name}}'), isTrue);
    });

    test('returns false for templates with no tokens', () {
      expect(MethodNamer.hasToken('removeAll'), isFalse);
      expect(MethodNamer.hasToken('refresh'), isFalse);
      expect(MethodNamer.hasToken('save'), isFalse);
      expect(MethodNamer.hasToken(''), isFalse);
    });

    test('returns false for partial/malformed tokens', () {
      expect(MethodNamer.hasToken('{{name}'), isFalse);
      expect(MethodNamer.hasToken('{name}}'), isFalse);
      expect(MethodNamer.hasToken('{{ name }}'), isFalse);
    });
  });
}
