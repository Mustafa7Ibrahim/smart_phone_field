# Smart Phone Field

A fully customizable Flutter phone number text field with automatic country detection and validation.

## Features

- **Auto-Detection**: Automatically detects the country as the user types the phone number
- **Country Selection**: Beautiful bottom sheet for manual country selection
- **Full Validation**: Validates phone numbers based on country-specific patterns
- **Fully Customizable**: Uses delegate pattern for complete control over appearance and behavior
- **SOLID Principles**: Built with clean architecture and separation of concerns
- **Material Design 3**: Modern, beautiful UI that works with your theme
- **195 Countries**: Comprehensive database of UN member countries

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  smart_phone_field: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Basic Usage

```dart
import 'package:smart_phone_field/smart_phone_field.dart';

class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final PhoneFieldController controller = PhoneFieldController();

  @override
  Widget build(BuildContext context) {
    return SmartPhoneField(
      controller: controller,
      onCountryChanged: (country) {
        print('Country: ${country?.name}');
      },
      onPhoneNumberChanged: (number) {
        print('Number: $number');
      },
      onValidationChanged: (isValid) {
        print('Valid: $isValid');
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

## Advanced Usage

### Custom Styling with Delegates

The package uses the delegate pattern to allow full customization without modifying the core widget:

```dart
SmartPhoneField(
  phoneFieldDelegate: DefaultPhoneFieldDelegate(
    labelText: 'Mobile Number',
    hintText: 'Enter your mobile number',
    focusedBorderColor: Colors.purple,
    errorBorderColor: Colors.orange,
    onCountryChangedCallback: (old, newCountry) {
      print('Country changed from ${old?.name} to ${newCountry?.name}');
    },
  ),
  countryPickerDelegate: DefaultCountryPickerDelegate(
    title: 'Choose Your Country',
    searchHint: 'Search for a country...',
    showDialCode: true,
    showFlag: true,
    itemHeight: 64,
  ),
)
```

### Creating Custom Delegates

Implement your own delegate for complete control:

```dart
class MyCustomPhoneFieldDelegate implements PhoneFieldDelegate {
  @override
  InputDecoration buildInputDecoration(
    BuildContext context,
    CountryData? selectedCountry,
    bool hasError,
  ) {
    return InputDecoration(
      labelText: 'Phone',
      filled: true,
      fillColor: Colors.grey[100],
      // ... your custom styling
    );
  }

  @override
  Widget? buildCountrySelector(
    BuildContext context,
    CountryData? selectedCountry,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ... your custom country selector widget
      ),
    );
  }

  // Implement other required methods...
}
```

### Controller Usage

The `PhoneFieldController` provides programmatic control:

```dart
final controller = PhoneFieldController(
  initialCountry: usCountry,
  initialPhoneNumber: '+1234567890',
  autoDetectionEnabled: true,
);

// Get the full international number
String fullNumber = controller.fullPhoneNumber;

// Validate
bool isValid = controller.validate();

// Get selected country
CountryData? country = controller.selectedCountry;

// Set country manually
controller.setCountry(ukCountry);

// Clear the field
controller.clear();
```

## Architecture

This package follows SOLID principles and clean architecture:

### Single Responsibility Principle (SRP)
- `PhoneFieldController`: Manages state and business logic
- `SmartPhoneField`: Handles UI rendering
- `CountryPickerSheet`: Manages country selection UI
- `PhoneValidator`: Validates phone numbers

### Open/Closed Principle (OCP)
- Delegates allow extending behavior without modifying core classes
- `PhoneFieldDelegate` and `CountryPickerDelegate` define extension points

### Liskov Substitution Principle (LSP)
- Any `PhoneFieldDelegate` implementation can replace `DefaultPhoneFieldDelegate`
- Any `CountryPickerDelegate` implementation can replace `DefaultCountryPickerDelegate`

### Interface Segregation Principle (ISP)
- Focused interfaces that don't force implementations to depend on unused methods

### Dependency Inversion Principle (DIP)
- High-level widgets depend on abstractions (delegates), not concrete implementations
- Easily testable and mockable

## Components

### SmartPhoneField

The main widget that provides the phone input field.

**Properties:**
- `controller`: Controller for managing state
- `phoneFieldDelegate`: Delegate for customizing appearance
- `countryPickerDelegate`: Delegate for customizing country picker
- `onCountryChanged`: Callback when country changes
- `onPhoneNumberChanged`: Callback when number changes
- `onValidationChanged`: Callback when validation state changes

### PhoneFieldController

Controller for managing phone field state.

**Methods:**
- `setCountry(CountryData?)`: Set the country manually
- `setPhoneNumber(String)`: Set the phone number
- `validate()`: Validate the current number
- `clear()`: Clear the field

**Properties:**
- `selectedCountry`: Currently selected country
- `phoneNumber`: Current phone number text
- `fullPhoneNumber`: Complete international format
- `isValid`: Current validation state
- `errorMessage`: Current error message

### Delegates

#### PhoneFieldDelegate
Customizes the text field appearance and behavior.

**Methods:**
- `buildInputDecoration()`: Customize input decoration
- `buildCountrySelector()`: Customize country selector widget
- `onCountryChanged()`: Handle country changes
- `onPhoneNumberChanged()`: Handle number changes
- `onValidationChanged()`: Handle validation changes
- `formatPhoneNumber()`: Custom number formatting
- `validatePhoneNumber()`: Custom validation

#### CountryPickerDelegate
Customizes the country picker bottom sheet.

**Methods:**
- `buildSheetHeader()`: Customize header
- `buildSearchBar()`: Customize search bar
- `buildCountryItem()`: Customize country item
- `buildSheetFooter()`: Customize footer
- `filterCountries()`: Custom search logic
- `sortCountries()`: Custom sorting

## Country Data

Access country information:

```dart
import 'package:smart_phone_field/smart_phone_field.dart';

// Get all countries
List<CountryData> allCountries = countries;

// Get country by code
CountryData? us = PhoneValidator.getCountryByCode('US');

// Get country by name
CountryData? egypt = PhoneValidator.getCountryByName('Egypt');

// Detect country from number
CountryData? detected = PhoneValidator.detectCountry('+201234567890');

// Validate international number
bool valid = PhoneValidator.validateInternational('+201234567890');
```

## Example

Check out the [example](example/lib/main.dart) directory for a complete working example.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
