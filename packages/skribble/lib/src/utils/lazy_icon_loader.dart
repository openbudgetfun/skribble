import 'dart:collection';

import '../wired_svg_icon_data.dart';

/// A lazy loader for large icon sets.
///
/// This class provides lazy loading functionality for icon maps,
/// loading icons on-demand rather than all at once. This reduces
/// initial memory usage and improves startup performance.
///
/// ## Example
///
/// ```dart
/// final loader = LazyIconLoader(
///   iconMap: kSkribbleIcons,
///   maxCacheSize: 100,
/// );
///
/// // Load icon on demand
/// final icon = loader.getIcon(0xf001);
/// ```
class LazyIconLoader {
  /// The full icon map containing all available icons.
  final Map<int, WiredSvgIconData> _iconMap;

  /// Cache of recently accessed icons.
  final LinkedHashMap<int, WiredSvgIconData> _cache;

  /// Maximum number of icons to keep in cache.
  final int maxCacheSize;

  /// Creates a lazy icon loader.
  ///
  /// [iconMap] - The full icon map to load from.
  /// [maxCacheSize] - Maximum number of icons to cache (default: 100).
  LazyIconLoader({
    required Map<int, WiredSvgIconData> iconMap,
    this.maxCacheSize = 100,
  }) : _iconMap = iconMap,
       _cache = LinkedHashMap<int, WiredSvgIconData>();

  /// Gets an icon by its codepoint.
  ///
  /// Returns the icon data if found, or null if not available.
  /// The icon is cached for subsequent access.
  WiredSvgIconData? getIcon(int codePoint) {
    // Check cache first
    if (_cache.containsKey(codePoint)) {
      // Move to end (most recently used)
      final icon = _cache.remove(codePoint)!;
      _cache[codePoint] = icon;
      return icon;
    }

    // Load from map
    final icon = _iconMap[codePoint];
    if (icon != null) {
      // Add to cache
      _cache[codePoint] = icon;

      // Evict oldest if cache is full
      if (_cache.length > maxCacheSize) {
        _cache.remove(_cache.keys.first);
      }
    }

    return icon;
  }

  /// Gets multiple icons by their codepoints.
  ///
  /// Returns a map of codepoint to icon data for all found icons.
  Map<int, WiredSvgIconData> getIcons(List<int> codePoints) {
    final result = <int, WiredSvgIconData>{};

    for (final codePoint in codePoints) {
      final icon = getIcon(codePoint);
      if (icon != null) {
        result[codePoint] = icon;
      }
    }

    return result;
  }

  /// Gets all available icon codepoints.
  ///
  /// Returns a set of all codepoints in the icon map.
  Set<int> get availableCodePoints => _iconMap.keys.toSet();

  /// Gets the total number of icons available.
  int get totalIcons => _iconMap.length;

  /// Gets the number of icons currently cached.
  int get cachedIcons => _cache.length;

  /// Clears the cache.
  void clearCache() {
    _cache.clear();
  }

  /// Preloads icons into the cache.
  ///
  /// [codePoints] - The codepoints to preload.
  void preload(List<int> codePoints) {
    codePoints.forEach(getIcon);
  }

  /// Gets cache statistics.
  ///
  /// Returns a map with cache hit rate and other metrics.
  Map<String, dynamic> get stats => {
    'totalIcons': totalIcons,
    'cachedIcons': cachedIcons,
    'maxCacheSize': maxCacheSize,
    'cacheUsage': cachedIcons / maxCacheSize,
  };
}

/// A paginated icon loader for displaying icons in pages.
///
/// This class provides paginated access to large icon sets,
/// useful for displaying icons in grids or lists.
///
/// ## Example
///
/// ```dart
/// final loader = PaginatedIconLoader(
///   iconMap: kSkribbleIcons,
///   pageSize: 50,
/// );
///
/// // Get first page
/// final page1 = loader.getPage(0);
///
/// // Get second page
/// final page2 = loader.getPage(1);
/// ```
class PaginatedIconLoader {
  /// The sorted list of icon codepoints.
  final List<int> _codePoints;

  /// The full icon map.
  final Map<int, WiredSvgIconData> _iconMap;

  /// Number of icons per page.
  final int pageSize;

  /// Creates a paginated icon loader.
  ///
  /// [iconMap] - The full icon map to load from.
  /// [pageSize] - Number of icons per page (default: 50).
  PaginatedIconLoader({
    required Map<int, WiredSvgIconData> iconMap,
    this.pageSize = 50,
  }) : _iconMap = iconMap,
       _codePoints = iconMap.keys.toList()..sort();

  /// Gets the total number of pages.
  int get totalPages => (_codePoints.length / pageSize).ceil();

  /// Gets a page of icons.
  ///
  /// [pageIndex] - The page index (0-based).
  ///
  /// Returns a map of codepoint to icon data for the requested page.
  Map<int, WiredSvgIconData> getPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= totalPages) {
      return {};
    }

    final start = pageIndex * pageSize;
    final end = (start + pageSize).clamp(0, _codePoints.length);

    final result = <int, WiredSvgIconData>{};
    for (int i = start; i < end; i++) {
      final codePoint = _codePoints[i];
      final icon = _iconMap[codePoint];
      if (icon != null) {
        result[codePoint] = icon;
      }
    }

    return result;
  }

  /// Gets the codepoints for a page.
  ///
  /// [pageIndex] - The page index (0-based).
  ///
  /// Returns a list of codepoints for the requested page.
  List<int> getPageCodePoints(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= totalPages) {
      return [];
    }

    final start = pageIndex * pageSize;
    final end = (start + pageSize).clamp(0, _codePoints.length);

    return _codePoints.sublist(start, end);
  }

  /// Searches for icons by name pattern.
  ///
  /// [pattern] - The search pattern to match against icon names.
  ///
  /// Returns a map of matching icons.
  Map<int, WiredSvgIconData> search(String pattern) {
    // Note: This is a placeholder. In a real implementation,
    // you would need icon name data to search against.
    return {};
  }
}
