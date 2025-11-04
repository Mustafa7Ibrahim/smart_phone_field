import 'package:flutter/material.dart';
import '../models/country_data.dart';

/// Delegate protocol for customizing the country picker bottom sheet.
///
/// This follows the delegate pattern to provide full control over the
/// appearance and behavior of the country selection UI.
///
/// Example:
/// ```dart
/// class MyCountryPickerDelegate implements CountryPickerDelegate {
///   @override
///   Widget buildSheetHeader(BuildContext context) {
///     return Text('Select Country', style: TextStyle(fontSize: 20));
///   }
///
///   @override
///   Widget buildCountryItem(
///     BuildContext context,
///     CountryData country,
///     bool isSelected,
///   ) {
///     return ListTile(
///       leading: Text(country.flag, style: TextStyle(fontSize: 30)),
///       title: Text(country.name),
///       trailing: Text(country.dialCode),
///       selected: isSelected,
///     );
///   }
/// }
/// ```
abstract class CountryPickerDelegate {
  /// Builds the header section of the bottom sheet.
  ///
  /// This is typically used for the title and close button.
  Widget buildSheetHeader(BuildContext context);

  /// Builds the search bar widget.
  ///
  /// Return null to hide the search functionality.
  Widget? buildSearchBar(
    BuildContext context,
    TextEditingController searchController,
    ValueChanged<String> onSearchChanged,
  );

  /// Builds a single country item in the list.
  ///
  /// - [country]: The country data to display
  /// - [isSelected]: Whether this country is currently selected
  /// - [onTap]: Callback when the item is tapped
  Widget buildCountryItem(
    BuildContext context,
    CountryData country,
    bool isSelected,
    VoidCallback onTap,
  );

  /// Builds the footer section of the bottom sheet.
  ///
  /// Return null to hide the footer.
  Widget? buildSheetFooter(BuildContext context);

  /// Builds a divider between country items.
  ///
  /// Return null to hide dividers.
  Widget? buildItemDivider(BuildContext context);

  /// Filters countries based on search query.
  ///
  /// Override this to implement custom search logic.
  List<CountryData> filterCountries(
    List<CountryData> countries,
    String searchQuery,
  );

  /// Sorts countries for display.
  ///
  /// Override this to implement custom sorting (e.g., by popularity).
  List<CountryData> sortCountries(List<CountryData> countries);

  /// Returns the background color of the sheet.
  Color? getSheetBackgroundColor(BuildContext context);

  /// Returns the shape of the sheet (for rounded corners, etc.).
  ShapeBorder? getSheetShape(BuildContext context);

  /// Returns the initial height of the bottom sheet as a fraction of screen height.
  ///
  /// Value should be between 0.0 and 1.0. Default is 0.7 (70% of screen).
  double get initialSheetHeight => 0.7;

  /// Returns the maximum height of the bottom sheet as a fraction of screen height.
  ///
  /// Value should be between 0.0 and 1.0. Default is 0.9 (90% of screen).
  double get maxSheetHeight => 0.9;

  /// Whether the sheet is draggable.
  bool get isDraggable => true;

  /// Whether to show a drag handle at the top of the sheet.
  bool get showDragHandle => true;

  /// Whether to enable search functionality.
  bool get enableSearch => true;
}
