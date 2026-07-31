/// The three Home Assistant `cover` services this app exposes.
///
/// Pressing "open"/"close" starts continuous movement on the physical
/// cover — Home Assistant itself drives it until it reaches the end
/// position or `stop` is called; the app never times the movement itself.
enum CoverAction { open, close, stop }
