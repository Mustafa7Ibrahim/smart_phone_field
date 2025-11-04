import 'package:flutter/material.dart';
import '../models/country_data.dart';
import 'country_picker_delegate.dart';

/// Default implementation of [CountryPickerDelegate] with Material Design styling.
///
/// This provides a beautiful, user-friendly country picker with search
/// functionality and proper styling that works well with most apps.
///
/// Example:
/// ```dart
/// // Use with custom settings
/// final delegate = DefaultCountryPickerDelegate(
///   title: 'Select Your Country',
///   searchHint: 'Search countries...',
///   showDialCode: true,
/// );
/// ```
class DefaultCountryPickerDelegate implements CountryPickerDelegate {
  /// The title to show in the header.
  final String title;

  /// The hint text for the search bar.
  final String searchHint;

  /// Whether to show the dial code in country items.
  final bool showDialCode;

  /// Whether to show the country flag.
  final bool showFlag;

  /// Custom background color for the sheet.
  final Color? backgroundColor;

  /// Custom shape for the sheet.
  final ShapeBorder? shapeOverride;

  /// Custom text style for country names.
  final TextStyle? countryNameStyle;

  /// Custom text style for dial codes.
  final TextStyle? dialCodeStyle;

  /// The height of each country item.
  final double itemHeight;

  /// Whether to show dividers between items.
  final bool showDividers;

  @override
  final double initialSheetHeight;

  @override
  final double maxSheetHeight;

  @override
  final bool isDraggable;

  @override
  final bool showDragHandle;

  @override
  final bool enableSearch;

  /// Creates a default country picker delegate.
  const DefaultCountryPickerDelegate({
    this.title = 'Select Country',
    this.searchHint = 'Search countries...',
    this.showDialCode = true,
    this.showFlag = true,
    this.backgroundColor,
    this.shapeOverride,
    this.countryNameStyle,
    this.dialCodeStyle,
    this.itemHeight = 56.0,
    this.showDividers = true,
    this.initialSheetHeight = 0.7,
    this.maxSheetHeight = 0.9,
    this.isDraggable = true,
    this.showDragHandle = true,
    this.enableSearch = true,
  });

  @override
  Widget buildSheetHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildSearchBar(
    BuildContext context,
    TextEditingController searchController,
    ValueChanged<String> onSearchChanged,
  ) {
    if (!enableSearch) return null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildCountryItem(
    BuildContext context,
    CountryData country,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: itemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        child: Row(
          children: [
            if (showFlag) ...[
              Text(
                country.flag,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                country.name,
                style: countryNameStyle ??
                    theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showDialCode) ...[
              const SizedBox(width: 8),
              Text(
                country.dialCode,
                style: dialCodeStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget? buildSheetFooter(BuildContext context) {
    // No footer by default
    return null;
  }

  @override
  Widget? buildItemDivider(BuildContext context) {
    if (!showDividers) return null;

    return Divider(
      height: 1,
      indent: showFlag ? 72 : 24,
      endIndent: 24,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
    );
  }

  @override
  List<CountryData> filterCountries(
    List<CountryData> countries,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return countries;

    final query = searchQuery.toLowerCase();

    return countries.where((country) {
      return country.name.toLowerCase().contains(query) ||
          country.code.toLowerCase().contains(query) ||
          country.dialCode.contains(query);
    }).toList();
  }

  @override
  List<CountryData> sortCountries(List<CountryData> countries) {
    // Sort alphabetically by name
    final sorted = [...countries];
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  @override
  Color? getSheetBackgroundColor(BuildContext context) {
    return backgroundColor ?? Theme.of(context).colorScheme.surface;
  }

  @override
  ShapeBorder? getSheetShape(BuildContext context) {
    return shapeOverride ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        );
  }
}
