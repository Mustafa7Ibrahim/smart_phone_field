import 'package:equatable/equatable.dart';

/// Represents country-specific phone number data including validation patterns.
///
/// This immutable class holds all information needed to validate and format
/// phone numbers for a specific country. It uses cached RegExp objects for
/// optimal performance when validating multiple phone numbers.
///
/// Example:
/// ```dart
/// final us = CountryData(
///   name: 'United States',
///   code: 'US',
///   dialCode: '+1',
///   flag: '🇺🇸',
///   pattern: r'^1',
///   localPatterns: [r'^[2-9][0-9]{9}$'],
///   priority: -10,
/// );
///
/// print(us.displayName); // '🇺🇸 United States (+1)'
/// print(us.matchesPattern('+1 234 567 8900')); // true
/// print(us.validateLocal('234 567 8900')); // true
/// ```
class CountryData extends Equatable {
  /// Regex pattern for cleaning phone numbers (removes spaces, dashes, parentheses, and plus)
  static final _phoneCleaningRegex = RegExp(r'[\s\-\(\)\+]');

  /// Regex pattern for cleaning local phone numbers (removes spaces, dashes, and parentheses)
  static final _localCleaningRegex = RegExp(r'[\s\-\(\)]');

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

  /// Cached RegExp for pattern matching (performance optimization)
  late final RegExp _patternRegex = RegExp(pattern);

  /// Cached RegExp list for local pattern validation (performance optimization)
  late final List<RegExp> _localPatternRegexes =
      localPatterns.map((p) => RegExp(p)).toList();

  CountryData({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.pattern,
    required this.localPatterns,
    this.priority = 0,
  })  : assert(name.isNotEmpty, 'Name cannot be empty'),
        assert(code.length == 2, 'Code must be ISO 3166-1 alpha-2 (2 chars)'),
        assert(
          dialCode.isNotEmpty && dialCode.startsWith('+'),
          'Dial code must start with +',
        );

  /// Returns the dial code without the '+' prefix.
  ///
  /// Example:
  /// ```dart
  /// final us = CountryData(..., dialCode: '+1', ...);
  /// print(us.dialCodeDigits); // '1'
  /// ```
  String get dialCodeDigits => dialCode.substring(1);

  /// Returns a formatted display string (e.g., "🇺🇸 United States (+1)").
  ///
  /// Example:
  /// ```dart
  /// final us = CountryData(name: 'United States', ..., flag: '🇺🇸', dialCode: '+1', ...);
  /// print(us.displayName); // '🇺🇸 United States (+1)'
  /// ```
  String get displayName => '$flag $name ($dialCode)';

  /// Checks if this country's pattern matches the given phone number.
  ///
  /// Example:
  /// ```dart
  /// final us = CountryData(name: 'United States', code: 'US', dialCode: '+1', ...);
  /// us.matchesPattern('+1 234 567 8900'); // true
  /// us.matchesPattern('+44 20 1234 5678'); // false
  /// ```
  bool matchesPattern(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(_phoneCleaningRegex, '');
    return _patternRegex.hasMatch(cleanNumber);
  }

  /// Validates a local phone number against this country's patterns.
  ///
  /// Example:
  /// ```dart
  /// final us = CountryData(name: 'United States', code: 'US', ...);
  /// us.validateLocal('234 567 8900'); // true if matches US pattern
  /// us.validateLocal('123'); // false (too short)
  /// ```
  bool validateLocal(String localNumber) {
    final cleanNumber = localNumber.replaceAll(_localCleaningRegex, '');
    return _localPatternRegexes.any((regex) => regex.hasMatch(cleanNumber));
  }

  @override
  List<Object?> get props => [
        name,
        code,
        dialCode,
        flag,
        pattern,
        localPatterns,
        priority,
      ];

  @override
  String toString() {
    return 'CountryData(name: $name, code: $code, dialCode: $dialCode)';
  }
}
