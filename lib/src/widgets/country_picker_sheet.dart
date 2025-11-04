import 'package:flutter/material.dart';
import '../data/all_countries.dart';
import '../models/country_data.dart';
import '../delegates/country_picker_delegate.dart';
import '../delegates/default_country_picker_delegate.dart';

/// A customizable bottom sheet for selecting a country.
///
/// This widget provides a fully customizable country picker that can be
/// styled and configured using a [CountryPickerDelegate].
///
/// Example:
/// ```dart
/// // Show the country picker
/// final selectedCountry = await showCountryPickerSheet(
///   context: context,
///   selectedCountry: currentCountry,
/// );
///
/// // Show with custom delegate
/// final selectedCountry = await showCountryPickerSheet(
///   context: context,
///   delegate: MyCustomCountryPickerDelegate(),
/// );
/// ```
class CountryPickerSheet extends StatefulWidget {
  /// The currently selected country (will be highlighted).
  final CountryData? selectedCountry;

  /// The delegate for customizing the appearance and behavior.
  final CountryPickerDelegate delegate;

  /// Creates a country picker sheet.
  const CountryPickerSheet({
    super.key,
    this.selectedCountry,
    CountryPickerDelegate? delegate,
  }) : delegate = delegate ?? const DefaultCountryPickerDelegate();

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  late final TextEditingController _searchController;
  late List<CountryData> _filteredCountries;
  late List<CountryData> _sortedCountries;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _sortedCountries = widget.delegate.sortCountries(countries);
    _filteredCountries = _sortedCountries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredCountries =
          widget.delegate.filterCountries(_sortedCountries, query);
    });
  }

  void _onCountrySelected(CountryData country) {
    Navigator.of(context).pop(country);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * widget.delegate.maxSheetHeight;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        color: widget.delegate.getSheetBackgroundColor(context),
        borderRadius: widget.delegate.getSheetShape(context) != null
            ? null
            : const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          if (widget.delegate.showDragHandle)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Header
          widget.delegate.buildSheetHeader(context),

          // Search bar
          if (widget.delegate.enableSearch)
            widget.delegate.buildSearchBar(
              context,
              _searchController,
              _onSearchChanged,
            ) ??
                const SizedBox.shrink(),

          // Country list
          Expanded(
            child: _filteredCountries.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (context, index) {
                      return widget.delegate.buildItemDivider(context) ??
                          const SizedBox.shrink();
                    },
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected =
                          country.code == widget.selectedCountry?.code;

                      return widget.delegate.buildCountryItem(
                        context,
                        country,
                        isSelected,
                        () => _onCountrySelected(country),
                      );
                    },
                  ),
          ),

          // Footer
          if (widget.delegate.buildSheetFooter(context) != null)
            widget.delegate.buildSheetFooter(context)!,
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No countries found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

/// Shows a country picker bottom sheet.
///
/// Returns the selected [CountryData] or null if the user cancels.
///
/// Example:
/// ```dart
/// final country = await showCountryPickerSheet(
///   context: context,
///   selectedCountry: currentCountry,
///   delegate: MyCustomDelegate(),
/// );
///
/// if (country != null) {
///   print('Selected: ${country.name}');
/// }
/// ```
Future<CountryData?> showCountryPickerSheet({
  required BuildContext context,
  CountryData? selectedCountry,
  CountryPickerDelegate? delegate,
}) {
  final effectiveDelegate = delegate ?? const DefaultCountryPickerDelegate();

  return showModalBottomSheet<CountryData>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: effectiveDelegate.isDraggable,
    backgroundColor: Colors.transparent,
    builder: (context) => CountryPickerSheet(
      selectedCountry: selectedCountry,
      delegate: effectiveDelegate,
    ),
  );
}
