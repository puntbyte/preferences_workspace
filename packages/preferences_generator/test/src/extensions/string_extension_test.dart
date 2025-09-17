import 'package:preferences_generator/src/extensions/string_extension.dart';
import 'package:test/test.dart';

void main() {
  group('StringCaseExtensions', () {
    group('toCamelCase', () {
      test('should convert from snake_case', () {
        expect('user_name'.toCamelCase(), 'userName');
        expect('user_id_from_api'.toCamelCase(), 'userIdFromApi');
      });

      test('should convert from PascalCase', () {
        expect('UserName'.toCamelCase(), 'userName');
        expect('UserIDFromAPI'.toCamelCase(), 'userIdFromApi');
      });

      test('should convert from kebab-case', () {
        expect('user-name'.toCamelCase(), 'userName');
        expect('user-id-from-api'.toCamelCase(), 'userIdFromApi');
      });

      test('should handle existing camelCase', () {
        expect('userName'.toCamelCase(), 'userName');
      });

      test('should handle single words', () {
        expect('username'.toCamelCase(), 'username');
        expect('Username'.toCamelCase(), 'username');
      });

      test('should handle all-caps words', () {
        expect('APIKey'.toCamelCase(), 'apiKey');
        expect('API_KEY'.toCamelCase(), 'apiKey');
      });

      test('should handle empty and whitespace strings', () {
        expect(''.toCamelCase(), '');
        expect('   '.toCamelCase(), '');
      });

      test('should handle strings with multiple separators', () {
        expect('user__name--test'.toCamelCase(), 'userNameTest');
      });
    });

    group('toPascalCase', () {
      test('should convert from snake_case', () {
        expect('user_name'.toPascalCase(), 'UserName');
        expect('user_id_from_api'.toPascalCase(), 'UserIdFromApi');
      });

      test('should convert from camelCase', () {
        expect('userName'.toPascalCase(), 'UserName');
      });

      test('should convert from kebab-case', () {
        expect('user-name'.toPascalCase(), 'UserName');
      });

      test('should handle existing PascalCase', () {
        expect('UserName'.toPascalCase(), 'UserName');
      });

      test('should handle single words', () {
        expect('username'.toPascalCase(), 'Username');
      });

      test('should handle all-caps words', () {
        expect('APIKey'.toPascalCase(), 'ApiKey');
        expect('API_KEY'.toPascalCase(), 'ApiKey');
      });

      test('should handle empty and whitespace strings', () {
        expect(''.toPascalCase(), '');
        expect('   '.toPascalCase(), '');
      });
    });

    group('toSnakeCase', () {
      test('should convert from camelCase', () {
        expect('userName'.toSnakeCase(), 'user_name');
        expect('userIdFromApi'.toSnakeCase(), 'user_id_from_api');
      });

      test('should convert from PascalCase', () {
        expect('UserName'.toSnakeCase(), 'user_name');
        expect('UserIDFromAPI'.toSnakeCase(), 'user_id_from_api');
      });

      test('should convert from kebab-case', () {
        expect('user-name'.toSnakeCase(), 'user_name');
      });

      test('should handle existing snake_case', () {
        expect('user_name'.toSnakeCase(), 'user_name');
      });

      test('should handle single words', () {
        expect('username'.toSnakeCase(), 'username');
      });

      test('should handle all-caps words', () {
        expect('APIKey'.toSnakeCase(), 'api_key');
        expect('API_KEY'.toSnakeCase(), 'api_key');
      });

      test('should handle empty and whitespace strings', () {
        expect(''.toSnakeCase(), '');
        expect('   '.toSnakeCase(), '');
      });
    });

    group('toKebabCase', () {
      test('should convert from camelCase', () {
        expect('userName'.toKebabCase(), 'user-name');
        expect('userIdFromApi'.toKebabCase(), 'user-id-from-api');
      });

      test('should convert from PascalCase', () {
        expect('UserName'.toKebabCase(), 'user-name');
        expect('UserIDFromAPI'.toKebabCase(), 'user-id-from-api');
      });

      test('should convert from snake_case', () {
        expect('user_name'.toKebabCase(), 'user-name');
      });

      test('should handle existing kebab-case', () {
        expect('user-name'.toKebabCase(), 'user-name');
      });

      test('should handle single words', () {
        expect('username'.toKebabCase(), 'username');
      });

      test('should handle all-caps words', () {
        expect('APIKey'.toKebabCase(), 'api-key');
        expect('API_KEY'.toKebabCase(), 'api-key');
      });

      test('should handle empty and whitespace strings', () {
        expect(''.toKebabCase(), '');
        expect('   '.toKebabCase(), '');
      });
    });
  });
}
