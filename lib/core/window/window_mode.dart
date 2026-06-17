/// Defines the two visual/window modes for ZenithTimer on the desktop.
enum WindowMode {
  /// Mode A: Borderless, full-screen background window acting as a
  /// dynamic wallpaper. Sits behind all other windows.
  dynamicWallpaper,

  /// Mode B: Small, always-on-top floating transparent widget that
  /// stays visible above all other windows.
  floatingWidget,
}
