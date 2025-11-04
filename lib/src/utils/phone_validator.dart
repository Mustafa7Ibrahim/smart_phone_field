import '../data/all_countries.dart';
import '../models/country_data.dart';

/// Utilities for validating and detecting phone numbers
class PhoneValidator {
  /// Detects the country from a phone number by matching patterns.
  /// Returns the matching country or null if no match found.
  ///
  /// The phone number can be in any format (with or without +, spaces, dashes, etc.).
  /// Countries with higher priority values are checked first to resolve ambiguities.
  ///
  /// Example:
  /// ```dart
  /// final country = PhoneValidator.detectCountry('+12685551234');
  /// // Returns Antigua and Barbuda (priority 10), not US/Canada (priority -10)
  /// ```
  static CountryData? detectCountry(String phoneNumber) {
    if (phoneNumber.isEmpty) return null;

    // Clean the phone number (remove all non-digit characters)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.isEmpty) return null;

    // Sort countries by priority (descending), so higher priority is checked first
    final sortedCountries = [...countries]
      ..sort((a, b) => b.priority.compareTo(a.priority));

    // Find the first matching country
    for (final country in sortedCountries) {
      if (country.matchesPattern(cleanNumber)) {
        return country;
      }
    }

    return null;
  }

  /// Detects all countries that match a phone number pattern.
  /// Useful when a number could belong to multiple countries.
  /// Results are sorted by priority (highest first).
  static List<CountryData> detectAllMatches(String phoneNumber) {
    if (phoneNumber.isEmpty) return [];

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.isEmpty) return [];

    final matches = countries.where((country) {
      return country.matchesPattern(cleanNumber);
    }).toList();

    // Sort by priority descending
    matches.sort((a, b) => b.priority.compareTo(a.priority));

    return matches;
  }

  /// Validates a complete phone number (international format).
  /// Returns true if the number matches a country's international pattern
  /// and its local validation pattern.
  static bool validateInternational(String phoneNumber) {
    final country = detectCountry(phoneNumber);
    if (country == null) return false;

    // Extract the local part after the dial code
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final dialCodeDigits = country.dialCode.replaceAll('+', '');

    if (!cleanNumber.startsWith(dialCodeDigits)) return false;

    final localNumber = cleanNumber.substring(dialCodeDigits.length);
    return country.validateLocal(localNumber);
  }

  /// Validates a local phone number for a specific country.
  static bool validateLocal(String localNumber, CountryData country) {
    return country.validateLocal(localNumber);
  }

  /// Formats a phone number to international format (+XX XXX XXX XXXX).
  /// This is a basic formatter - you may want to customize per country.
  static String formatInternational(String phoneNumber) {
    final country = detectCountry(phoneNumber);
    if (country == null) return phoneNumber;

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return '+$cleanNumber';
  }

  /// Gets all countries that share the same dial code as the given country.
  static List<CountryData> getCountriesWithSameDialCode(CountryData country) {
    return countries
        .where((c) => c.dialCode == country.dialCode && c.code != country.code)
        .toList();
  }

  /// Checks if a dial code is shared by multiple countries (like +1 for NANP).
  static bool isSharedDialCode(String dialCode) {
    final count = countries.where((c) => c.dialCode == dialCode).length;
    return count > 1;
  }

  /// Gets a country by its ISO code.
  static CountryData? getCountryByCode(String isoCode) {
    try {
      return countries.firstWhere(
        (c) => c.code.toLowerCase() == isoCode.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Gets a country by its name (case-insensitive).
  static CountryData? getCountryByName(String name) {
    try {
      return countries.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Gets all countries with a specific dial code.
  static List<CountryData> getCountriesByDialCode(String dialCode) {
    final normalized = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    return countries.where((c) => c.dialCode == normalized).toList();
  }
}
