import 'package:preferences_generator/src/models/method_config.dart';
import 'package:preferences_generator/src/utils/method_namer.dart';
import 'package:test/test.dart';

void main() {
  group('MethodNamer.getName', () {
    test('should apply prefix and PascalCase base', () {
      const config = ResolvedMethodConfig(enabled: true, prefix: 'set');
      final name = MethodNamer.getName('username', config);
      expect(name, 'setUsername');
    });

    test('should apply suffix', () {
      const config = ResolvedMethodConfig(enabled: true, suffix: 'Async');
      final name = MethodNamer.getName('username', config);
      expect(name, 'usernameAsync');
    });

    test('should apply both prefix and suffix', () {
      const config = ResolvedMethodConfig(enabled: true, prefix: 'get', suffix: 'Stream');
      final name = MethodNamer.getName('launch_count', config);
      expect(name, 'getLaunchCountStream');
    });

    test('should use name override above all else', () {
      const config = ResolvedMethodConfig(
        enabled: true,
        prefix: 'set',
        suffix: 'Async',
        name: 'changeUsername',
      );
      final name = MethodNamer.getName('username', config);
      expect(name, 'changeUsername');
    });

    test('should use base name when no affixes are present', () {
      const config = ResolvedMethodConfig(enabled: true);
      final name = MethodNamer.getName('username', config);
      expect(name, 'username');
    });
  });
}
