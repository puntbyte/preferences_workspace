import 'package:code_builder/code_builder.dart';

/// A utility class for programmatically building Dart syntax elements such as classes, methods,
/// fields, constructors, and more using the `code_builder` package.
///
/// This class is not meant to be instantiated.
class SyntaxWriter {
  const SyntaxWriter._();

  /// Creates a Dart class declaration.
  ///
  /// [name] specifies the name of the class. [extend] specifies the superclass to extend.
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
  }) => Class((builder) {
    builder.name = name;
    if (extend != null) builder.extend = extend;
    if (implements != null) builder.implements.addAll(implements);
    if (mixins != null) builder.mixins.addAll(mixins);
    if (fields != null) builder.fields.addAll(fields);
    if (constructors != null) builder.constructors.addAll(constructors);
    if (methods != null) builder.methods.addAll(methods);
  });

  /// Creates a Dart constructor.
  ///
  /// [requiredParameters] and [optionalParameters] define constructor parameters. [initializers]
  /// sets initializer list entries. [body] defines the constructor body.
  static Constructor constructor({
    List<Parameter>? requiredParameters,
    List<Parameter>? optionalParameters,
    List<Code>? initializers,
    Code? body,
  }) => Constructor((builder) {
    if (requiredParameters != null) builder.requiredParameters.addAll(requiredParameters);
    if (optionalParameters != null) builder.optionalParameters.addAll(optionalParameters);
    if (initializers != null) builder.initializers.addAll(initializers);
    if (body != null) builder.body = body;
  });

  /// Creates a Dart field.
  ///
  /// [name] is the name of the field. [type] sets the field type. [modifier] sets the field
  /// modifier (e.g., `final`, `var`). [isStatic] defines whether the field is static. [assignment]
  /// assigns a value to the field.
  static Field field({
    required String name,
    Reference? type,
    FieldModifier? modifier,
    bool? isStatic,
    Code? assignment,
  }) => Field((builder) {
    builder.name = name;
    if (type != null) builder.type = type;
    if (modifier != null) builder.modifier = modifier;
    if (isStatic != null) builder.static = isStatic;
    if (assignment != null) builder.assignment = assignment;
  });

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
    bool? isLambda,
    List<Parameter>? requiredParameters,
    List<Parameter>? optionalParameters,
    List<Expression>? annotations,
  }) => Method((builder) {
    builder.name = name;
    if (returns != null) builder.returns = returns;
    if (type != null) builder.type = type;
    if (modifier != null) builder.modifier = modifier;
    if (body != null) builder.body = body;
    if (isLambda != null) builder.lambda = isLambda;
    if (requiredParameters != null) builder.requiredParameters.addAll(requiredParameters);
    if (optionalParameters != null) builder.optionalParameters.addAll(optionalParameters);
    if (annotations != null) builder.annotations.addAll(annotations);
  });

  /// Creates a Dart mixin.
  ///
  /// [name] is the name of the mixin. [implements] specifies interfaces the mixin implements.
  /// [methods] adds methods to the mixin.
  static Mixin mixin({
    required String name,
    List<Reference>? implements,
    List<Method>? methods,
  }) => Mixin((builder) {
    builder.name = name;
    if (implements != null) builder.implements.addAll(implements);
    if (methods != null) builder.methods.addAll(methods);
  });

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
  }) => Parameter((builder) {
    builder.name = name;
    if (type != null) builder.type = type;
    builder.toThis = toThis;
    builder.named = isNamed;
    builder.required = isRequired;
    if (defaultTo != null) builder.defaultTo = defaultTo;
  });
}
