abstract interface class PrefsAdapter {
  const PrefsAdapter();

  Future<PrimitiveType?> get<PrimitiveType>(String key);

  Future<void> set<SupportedType>(String key, SupportedType value);

  Future<void> remove(String key);

  Future<void> removeAll();
}
