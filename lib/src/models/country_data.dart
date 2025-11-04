import 'package:equatable/equatable.dart';

/// Represents country-specific phone number data including validation patterns.
class CountryData extends Equatable {
  /// The full name of the country
  final String name;

  /// The ISO 3166-1 alpha-2 country code (e.g., 'US', 'EG')
  final String code;

  /// The international dialing code including the '+' prefix (e.g., '+1', '+20')
  final String dialCode;

  /// The country flag emoji
  final String flag;

  /// Regex pattern to match the international dial code without '+'
  final String pattern;

  /// List of regex patterns for validating local phone number formats
  final List<String> localPatterns;

  /// Priority for pattern matching (higher = checked first).
  /// Used to resolve ambiguity in NANP (+1) and other shared dial codes.
  /// Specific patterns (e.g., +1-268-xxx) should have higher priority than generic (+1).
  final int priority;

  const CountryData({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.pattern,
    required this.localPatterns,
    this.priority = 0,
  });

  /// Checks if this country's pattern matches the given phone number
  bool matchesPattern(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return RegExp(pattern).hasMatch(cleanNumber);
  }

  /// Validates a local phone number against this country's patterns
  bool validateLocal(String localNumber) {
    final cleanNumber = localNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return localPatterns.any((pattern) => RegExp(pattern).hasMatch(cleanNumber));
  }

  @override
  List<Object?> get props => [code, dialCode, pattern];

  @override
  String toString() {
    return 'CountryData(name: $name, code: $code, dialCode: $dialCode)';
  }
}
