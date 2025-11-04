# Smart Phone Field Example

This is a complete Flutter application demonstrating the usage of the `smart_phone_field` package.

## Features Demonstrated

- Basic phone field with auto-detection
- Real-time country detection as user types
- Phone number validation
- Custom styling with delegates
- Country picker bottom sheet
- State management with PhoneFieldController
- Success/error dialogs

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.2)
- A device or emulator/simulator to run the app

### Running the Example

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Get the dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Try It Out

1. **Auto-Detection**: Start typing a phone number with a country code (e.g., +201234567890 for Egypt, +1234567890 for US/Canada)
2. **Manual Selection**: Click on the country selector (flag + dial code) to manually choose a country
3. **Validation**: Click the "Validate" button to check if the phone number is valid
4. **Custom Styling**: Scroll down to see a second phone field with custom styling

## Code Structure

```
lib/
└── main.dart           # Main application with demo UI
```

## Key Components Used

- **SmartPhoneField**: The main phone input widget
- **PhoneFieldController**: Controller for managing phone field state
- **DefaultPhoneFieldDelegate**: Default styling for phone field
- **DefaultCountryPickerDelegate**: Default styling for country picker

## Customization Examples

The example app shows two implementations:

1. **Basic Usage** (top field):
   - Default styling
   - All callbacks enabled
   - Real-time state updates displayed

2. **Custom Styled** (bottom field):
   - Custom colors (purple focus, orange error)
   - Custom labels and hints
   - Custom country picker title and search placeholder

## Learn More

Check out the [main package README](../README.md) for detailed documentation and advanced usage.
