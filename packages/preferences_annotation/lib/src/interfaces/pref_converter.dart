abstract class PrefConverter<TypeEntry, TypeStorage> {
  /// The constructor must be `const`.
  const PrefConverter();

  /// Converts the object of type [TypeEntry] into its storable
  /// representation, [TypeStorage].
  TypeStorage toStorage(TypeEntry value);

  /// Converts the storable representation [TypeStorage] back into an
  /// object of type [TypeEntry].
  TypeEntry fromStorage(TypeStorage value);
}
