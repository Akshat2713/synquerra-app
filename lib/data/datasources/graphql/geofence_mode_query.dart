/// Central place for all GraphQL queries/mutations.
class GeofenceModeQuery {
  GeofenceModeQuery._();

  /// Fetch modes filtered by category.
  /// Variables: $category (String), $isActive (Boolean)
  static const String modes = r'''
    query Modes($category: String, $isActive: Boolean) {
      modes(category: $category, isActive: $isActive) {
        id
        name
        categories
        description
      }
    }
  ''';
}
