import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/phone_field_controller.dart';
import '../delegates/phone_field_delegate.dart';
import '../delegates/default_phone_field_delegate.dart';
import '../delegates/country_picker_delegate.dart';
import '../delegates/default_country_picker_delegate.dart';
import '../models/country_data.dart';
import 'country_picker_sheet.dart';

/// A smart phone number text field with automatic country detection.
///
/// This widget provides a fully customizable phone input field that:
/// - Automatically detects the country from the phone number as the user types
/// - Allows manual country selection via a bottom sheet
/// - Validates phone numbers based on the selected country
/// - Supports complete customization via delegates
///
/// Example:
/// ```dart
/// SmartPhoneField(
///   controller: phoneController,
///   onCountryChanged: (country) {
///     print('Country: ${country?.name}');
///   },
///   onPhoneNumberChanged: (number) {
///     print('Number: $number');
///   },
/// )
/// ```
///
/// Example with custom delegates:
/// ```dart
/// SmartPhoneField(
///   controller: phoneController,
///   phoneFieldDelegate: MyCustomPhoneFieldDelegate(),
///   countryPickerDelegate: MyCustomCountryPickerDelegate(),
/// )
/// ```
class SmartPhoneField extends StatefulWidget {
  /// The controller for managing the phone field state.
  final PhoneFieldController? controller;

  /// Delegate for customizing the text field appearance and behavior.
  final PhoneFieldDelegate? phoneFieldDelegate;

  /// Delegate for customizing the country picker bottom sheet.
  final CountryPickerDelegate? countryPickerDelegate;

  /// Callback when the selected country changes.
  final void Function(CountryData? country)? onCountryChanged;

  /// Callback when the phone number changes.
  final void Function(String phoneNumber)? onPhoneNumberChanged;

  /// Callback when validation state changes.
  final void Function(bool isValid)? onValidationChanged;

  /// The initial country to select.
  final CountryData? initialCountry;

  /// The initial phone number to display.
  final String? initialPhoneNumber;

  /// Whether to enable auto-detection of country from phone number.
  final bool autoDetectionEnabled;

  /// The keyboard type for the text field.
  final TextInputType keyboardType;

  /// Input formatters for the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node for the text field.
  final FocusNode? focusNode;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to show the country selector button.
  final bool showCountrySelector;

  /// Creates a smart phone field.
  const SmartPhoneField({
    super.key,
    this.controller,
    this.phoneFieldDelegate,
    this.countryPickerDelegate,
    this.onCountryChanged,
    this.onPhoneNumberChanged,
    this.onValidationChanged,
    this.initialCountry,
    this.initialPhoneNumber,
    this.autoDetectionEnabled = true,
    this.keyboardType = TextInputType.phone,
    this.inputFormatters,
    this.focusNode,
    this.enabled = true,
    this.showCountrySelector = true,
  });

  @override
  State<SmartPhoneField> createState() => _SmartPhoneFieldState();
}

class _SmartPhoneFieldState extends State<SmartPhoneField> {
  late final PhoneFieldController _controller;
  late final PhoneFieldDelegate _phoneFieldDelegate;
  late final CountryPickerDelegate _countryPickerDelegate;
  bool _isInternalController = false;

  CountryData? _previousCountry;
  String _previousPhoneNumber = '';
  bool _previousValidationState = false;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = PhoneFieldController(
        initialCountry: widget.initialCountry,
        initialPhoneNumber: widget.initialPhoneNumber,
        autoDetectionEnabled: widget.autoDetectionEnabled,
      );
      _isInternalController = true;
    }

    // Initialize delegates
    _phoneFieldDelegate =
        widget.phoneFieldDelegate ?? const DefaultPhoneFieldDelegate();
    _countryPickerDelegate =
        widget.countryPickerDelegate ?? const DefaultCountryPickerDelegate();

    // Set initial previous values
    _previousCountry = _controller.selectedCountry;
    _previousPhoneNumber = _controller.phoneNumber;
    _previousValidationState = _controller.isValid;

    // Listen to controller changes
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(SmartPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If controller changed, update listener
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onControllerChanged);

      if (widget.controller != null) {
        if (_isInternalController) {
          _controller.dispose();
        }
        _controller = widget.controller!;
        _isInternalController = false;
      }

      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    // Check if country changed
    if (_controller.selectedCountry != _previousCountry) {
      final oldCountry = _previousCountry;
      final newCountry = _controller.selectedCountry;
      _previousCountry = newCountry;

      // Notify delegate
      _phoneFieldDelegate.onCountryChanged(oldCountry, newCountry);

      // Notify callback
      widget.onCountryChanged?.call(newCountry);

      // Rebuild to update UI
      setState(() {});
    }

    // Check if phone number changed
    if (_controller.phoneNumber != _previousPhoneNumber) {
      _previousPhoneNumber = _controller.phoneNumber;

      // Notify delegate
      _phoneFieldDelegate.onPhoneNumberChanged(_controller.phoneNumber);

      // Notify callback
      widget.onPhoneNumberChanged?.call(_controller.phoneNumber);
    }

    // Check if validation state changed
    if (_controller.isValid != _previousValidationState) {
      _previousValidationState = _controller.isValid;

      // Notify delegate
      _phoneFieldDelegate.onValidationChanged(
        _controller.isValid,
        _controller.errorMessage,
      );

      // Notify callback
      widget.onValidationChanged?.call(_controller.isValid);

      // Rebuild to update error state
      setState(() {});
    }
  }

  Future<void> _onCountrySelectorTapped() async {
    // Show country picker
    final selectedCountry = await showCountryPickerSheet(
      context: context,
      selectedCountry: _controller.selectedCountry,
      delegate: _countryPickerDelegate,
    );

    // Update controller if a country was selected
    if (selectedCountry != null) {
      _controller.setCountry(selectedCountry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final delegate = _phoneFieldDelegate;
    final hasError = !_controller.isValid && _controller.phoneNumber.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country selector
        if (widget.showCountrySelector && delegate.showCountrySelector)
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: delegate.buildCountrySelector(
                  context,
                  _controller.selectedCountry,
                  _onCountrySelectorTapped,
                ) ??
                const SizedBox.shrink(),
          ),

        // Phone number text field
        Expanded(
          child: TextField(
            controller: _controller.textController,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            textDirection: delegate.textDirection,
            inputFormatters: widget.inputFormatters,
            decoration: delegate.buildInputDecoration(
              context,
              _controller.selectedCountry,
              hasError,
            ).copyWith(
              errorText: hasError ? _controller.errorMessage : null,
            ),
            onChanged: (value) {
              // Apply custom formatting if provided
              final formatted = delegate.formatPhoneNumber(
                value,
                _controller.selectedCountry,
              );

              if (formatted != null && formatted != value) {
                // Update with formatted value
                _controller.textController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(
                    offset: formatted.length.clamp(0, formatted.length),
                  ),
                );
              }

              // Custom validation from delegate
              final customError = delegate.validatePhoneNumber(
                value,
                _controller.selectedCountry,
              );

              if (customError != null) {
                // Handle custom validation error
                // This could be implemented by adding a method to the controller
              }
            },
          ),
        ),
      ],
    );
  }
}
