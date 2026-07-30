/// Maps a Home Assistant entity's `entity_id`/friendly name text to one of
/// the app's local room ids via a German keyword table.
///
/// Deliberately text-based, not the Home Assistant Area Registry — a
/// registry-backed mapping would need additional websocket round trips
/// (`config/entity_registry/list` + `config/device_registry/list` +
/// `config/area_registry/list`, joined by hand) for little benefit over
/// matching on the id/name Home Assistant already gives us for free.
class HaAreaAliasMapper {
  const HaAreaAliasMapper();

  static const _aliases = <String, List<String>>{
    'livingRoom': ['wohnzimmer'],
    'bedroom': ['schlafzimmer'],
    'kitchen': ['küche', 'kueche'],
    'bathroom': ['bad'],
    'hallway': ['flur', 'diele'],
  };

  /// Returns the matching local room id, or `null` if no alias matches —
  /// callers treat that as "not assigned to any room yet".
  String? match({required String entityId, String? friendlyName}) {
    final haystack = '$entityId ${friendlyName ?? ''}'.toLowerCase();
    for (final entry in _aliases.entries) {
      if (entry.value.any(haystack.contains)) return entry.key;
    }
    return null;
  }
}
