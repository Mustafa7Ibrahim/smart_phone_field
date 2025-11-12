import 'package:flutter/material.dart';
import 'package:smart_phone_field/smart_phone_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Phone Field Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const PhoneFieldDemoPage(),
    );
  }
}

class PhoneFieldDemoPage extends StatefulWidget {
  const PhoneFieldDemoPage({super.key});

  @override
  State<PhoneFieldDemoPage> createState() => _PhoneFieldDemoPageState();
}

class _PhoneFieldDemoPageState extends State<PhoneFieldDemoPage> {
  final PhoneFieldController _controller = PhoneFieldController();
  CountryData? _selectedCountry;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Phone Field'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Basic Usage',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Default configuration with auto-detection',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Basic Phone Field
            SmartPhoneField(
              controller: _controller,
              onCountryChanged: (country) {
                setState(() => _selectedCountry = country);
              },
            ),

            const SizedBox(height: 32),

            // Custom Styling Example
            Text(
              'Custom Styling',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rounded borders, filled background, custom colors',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            SmartPhoneField(
              phoneFieldDelegate: DefaultPhoneFieldDelegate(
                labelText: 'Mobile Number',
                hintText: 'Enter your mobile',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: 16,
                focusedBorderColor: Colors.purple,
                enabledBorderColor: Colors.purple.withValues(alpha: 0.3),
              ),
            ),

            const SizedBox(height: 32),

            // With Icons
            Text(
              'With Icons & Helper Text',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            SmartPhoneField(
              phoneFieldDelegate: DefaultPhoneFieldDelegate(
                labelText: 'Phone',
                prefixIcon: const Icon(Icons.phone_outlined),
                suffixIcon: const Icon(Icons.contact_phone),
                helperText: 'We\'ll never share your number',
              ),
            ),

            const SizedBox(height: 32),

            // Minimal Style
            Text(
              'Minimal Style',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            SmartPhoneField(
              phoneFieldDelegate: DefaultPhoneFieldDelegate(
                hintText: 'Phone number',
                showDialCode: false,
                showDropdownIcon: false,
                borderRadius: 12,
                borderWidth: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // With Leading/Trailing
            Text(
              'With Custom Widgets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            SmartPhoneField(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.call,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scan QR code')),
                  );
                },
              ),
              spacing: 12,
            ),

            const SizedBox(height: 32),

            // Status Card
            if (_selectedCountry != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _selectedCountry!.flag,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedCountry!.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  _selectedCountry!.dialCode,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (_controller.isValid)
                            const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                      if (_controller.fullPhoneNumber.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(
                          'Full Number',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _controller.fullPhoneNumber,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _controller.phoneNumber.isEmpty
                        ? null
                        : () {
                            _controller.validate();
                            if (_controller.isValid) {
                              _showSuccessDialog();
                            } else {
                              _showErrorDialog();
                            }
                          },
                    child: const Text('Validate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _controller.clear();
                      setState(() => _selectedCountry = null);
                    },
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Customization Info
            Card(
              color:
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Customization Options',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeature('40+ styling parameters'),
                    _buildFeature('Custom delegates'),
                    _buildFeature('Custom widgets (leading/trailing)'),
                    _buildFeature('Full TextField properties'),
                    _buildFeature('Border, colors, padding control'),
                    _buildFeature('Flag size & selector customization'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Valid Phone Number'),
            content: Text(
              'Phone number ${_controller.fullPhoneNumber} is valid for ${_selectedCountry?.name ?? "selected country"}!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.error, color: Colors.red, size: 48),
            title: const Text('Invalid Phone Number'),
            content: Text(
              _controller.errorMessage ?? 'Please enter a valid phone number.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
