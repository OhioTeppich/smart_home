/// Maximum number of devices the user can add to the dashboard's
/// Schnellzugriff widget. Chosen so the tile row on the desktop layout
/// (`HomeOverview`'s second row, which only renders at width >= 780) never
/// wraps to a second line — see the tile-width arithmetic next to
/// `kQuickAccessTileWidth` in `quick_access_card.dart`.
const kQuickAccessMaxDevices = 3;
