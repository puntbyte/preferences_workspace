import 'package:code_builder/code_builder.dart';

/// A utility class for programmatically building Dart syntax elements such as
/// classes, methods, fields, constructors, and more using the `code_builder`
/// package.
///
/// This class is not meant to be instantiated.
class SyntaxBuilder {
  const SyntaxBuilder._();

  /// Creates a Dart library.
  ///
  /// [elements] are the main body of the library (e.g., classes, functions). [directives] are
  /// directives like imports or exports.
  static Library library({
    List<Spec> elements = const [],
    List<Directive> directives = const [],
  }) => Library((builder) {
    builder.body.addAll(elements);
    builder.directives.addAll(directives);
  });

  /// Creates a Dart class declaration.
  ///
  /// [name] specifies the name of the class. [extend] specifies the superclass
  /// to extend.
  /// [implements] specifies the interfaces to implement. [mixins] specifies the mixins to include.
  /// [constructors], [fields], and [methods] add corresponding class elements.
  static Class class$({
    required String name,
    Reference? extend,
    List<Reference>? implements,
    List<Reference>? mixins,
    List<Constructor>? constructors,
    List<Field>? fields,
    List<Method>? methods,
  }) => Class(
    (builder) => builder
      ..name = name
      ..extend = extend
      ..implements.addAll(implements ?? [])
      ..mixins.addAll(mixins ?? [])
      ..fields.addAll(fields ?? [])
      ..constructors.addAll(constructors ?? [])
      ..methods.addAll(methods ?? []),
  );

  /// Creates a Dart mixin.
  ///
  /// [name] is the name of the mixin. [implements] specifies interfaces the mixin implements.
  /// [methods] adds methods to the mixin.
  static Mixin mixin({
    required String name,
    Reference? on,
    List<Reference>? implements,
    List<Field>? fields,
    List<Method>? methods,
  }) => Mixin(
    (builder) => builder
      ..name = name
      ..implements.addAll(implements ?? [])
      ..fields.addAll(fields ?? [])
      ..methods.addAll(methods ?? []),
  );

  /// Creates a Dart field.
  ///
  /// [name] is the name of the field. [type] sets the field type. [modifier] sets the field
  /// modifier (e.g., `final`, `var`). [isStatic] defines whether the field is static. [assignment]
  /// assigns a value to the field.
  static Field field({
    required String name,
    Reference? type,
    FieldModifier? modifier,
    bool isStatic = false,
    bool isLate = false,
    Code? assignment,
    List<Expression>? annotations,
  }) => Field(
    (builder) {
      builder
        ..name = name
        ..type = type
        ..static = isStatic
        ..assignment = assignment
        ..annotations.addAll(annotations ?? [])
        ..late = isLate;
      if (modifier != null) builder.modifier = modifier;
    },
  );

  /// Creates a Dart constructor.
  ///
  /// [requiredParameters] and [optionalParameters] define constructor parameters. [initializers]
  /// sets initializer list entries. [body] defines the constructor body.
  static Constructor constructor({
    Parameter? requiredParameter,
    List<Parameter>? requiredParameters,
    Parameter? optionalParameter,
    List<Parameter>? optionalParameters,
    Code? initializer,
    List<Code>? initializers,
    Code? body,
  }) => Constructor(
    (builder) => builder
      ..requiredParameters.addAll(requiredParameters ?? [?requiredParameter])
      ..optionalParameters.addAll(optionalParameters ?? [?optionalParameter])
      ..initializers.addAll(initializers ?? [?initializer])
      ..body = body,
  );

  /// Creates a Dart method.
  ///
  /// [name] is the method name. [returns] specifies the return type. [type] defines the method
  /// type (normal, getter, setter). [modifier] defines method modifiers like `static`, `external`.
  /// [body] is the method implementation. [isLambda] makes the method a lambda if true.
  /// [requiredParameters] and [optionalParameters] define method parameters. [annotations] adds
  /// annotations to the method.
  static Method method({
    required String name,
    Reference? returns,
    MethodType? type,
    MethodModifier? modifier,
    Code? body,
    bool isLambda = false,
    List<Parameter>? requiredParameters,
    Parameter? requiredParameter,
    List<Parameter>? optionalParameters,
    Parameter? optionalParameter,
    List<Expression>? annotations,
    Expression? annotation,
  }) => Method(
    (builder) => builder
      ..name = name
      ..returns = returns
      ..type = type
      ..modifier = modifier
      ..body = body
      ..lambda = isLambda
      ..requiredParameters.addAll(requiredParameters ?? [?requiredParameter])
      ..optionalParameters.addAll(optionalParameters ?? [?optionalParameter])
      ..annotations.addAll(annotations ?? [?annotation]),
  );

  static Method abstractMethod({
    required String name,
    Reference? returns,
    MethodType? type,
    List<Parameter>? requiredParameters,
    List<Parameter>? optionalParameters,
    List<Expression>? annotations,
    List<String>? docs,
  }) => Method(
    (builder) => builder
      ..name = name
      ..returns = returns
      ..type = type
      ..docs.addAll(docs ?? [])
      ..requiredParameters.addAll(requiredParameters ?? [])
      ..optionalParameters.addAll(optionalParameters ?? []),
  );

  static Method abstractSetter({
    required String name,
    required Reference type,
    String parameterName = 'value',
  }) => Method(
    (builder) => builder
      ..name = name
      ..type = MethodType.setter
      ..requiredParameters.add(parameter(name: parameterName, type: type)),
  );

  /// Creates a Dart function or constructor parameter.
  ///
  /// [name] is the parameter name. [type] is the parameter type. [toThis] marks the parameter as
  /// `this.name`. [isNamed] makes the parameter a named argument. [isRequired] marks the named
  /// parameter as required. [defaultTo] sets the default value.
  static Parameter parameter({
    required String name,
    Reference? type,
    bool toThis = false,
    bool isNamed = false,
    bool isRequired = false,
    Code? defaultTo,
  }) => Parameter(
    (builder) => builder
      ..name = name
      ..type = type
      ..toThis = toThis
      ..named = isNamed
      ..required = isRequired
      ..defaultTo = defaultTo,
  );
}
