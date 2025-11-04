import '../data/all_countries.dart';
import '../models/country_data.dart';

/// Utilities for validating and detecting phone numbers
class PhoneValidator {
  // For faster lookups, we use maps to store countries by code and name.
  static final Map<String, CountryData> _countriesByCode = {
    for (var country in countries) country.code.toLowerCase(): country
  };

  static final Map<String, CountryData> _countriesByName = {
    for (var country in countries) country.name.toLowerCase(): country
  };

  /// Detects the country from a phone number by matching patterns.
  /// Returns the matching country or null if no match found.
  ///
  /// The phone number can be in any format (with or without +, spaces, dashes, etc.).
  /// Countries with higher priority values are checked first to resolve ambiguities.
  ///
  /// This method first tries to detect from international format (with dial code),
  /// and if that fails, it tries to detect from local format patterns.
  ///
  /// Example:
  /// ```dart
  /// final country = PhoneValidator.detectCountry('+12685551234');
  /// // Returns Antigua and Barbuda (priority 10), not US/Canada (priority -10)
  ///
  /// final country2 = PhoneValidator.detectCountry('0101248831');
  /// // Returns Egypt (detected from local pattern)
  /// ```
  static CountryData? detectCountry(String phoneNumber) {
    if (phoneNumber.isEmpty) return null;

    // Clean the phone number (remove all non-digit characters)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.isEmpty) return null;

    // Sort countries by priority (descending), so higher priority is checked first
    final sortedCountries = [...countries]
      ..sort((a, b) => b.priority.compareTo(a.priority));

    // First, try international format detection (with dial code)
    for (final country in sortedCountries) {
      if (country.matchesPattern(cleanNumber)) {
        return country;
      }
    }

    // If no match found, try local format detection
    return detectCountryFromLocal(phoneNumber);
  }

  /// Detects the country from a local phone number format.
  /// Returns the matching country or null if no match found.
  ///
  /// This method matches against each country's local patterns.
  /// Since local patterns can be ambiguous, the country with the highest
  /// priority that matches will be returned.
  ///
  /// Example:
  /// ```dart
  /// final country = PhoneValidator.detectCountryFromLocal('0101248831');
  /// // Returns Egypt (matches pattern ^0?(10|11|12|15)[0-9]{8}$)
  ///
  /// final country2 = PhoneValidator.detectCountryFromLocal('2025551234');
  /// // Returns United States (matches US local pattern)
  /// ```
  static CountryData? detectCountryFromLocal(String phoneNumber) {
    if (phoneNumber.isEmpty) return null;

    // Clean the phone number (remove spaces, dashes, parentheses, but keep digits)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanNumber.isEmpty) return null;

    // Sort countries by priority (descending), so higher priority is checked first
    final sortedCountries = [...countries]
      ..sort((a, b) => b.priority.compareTo(a.priority));

    // Find the first country whose local pattern matches
    for (final country in sortedCountries) {
      if (country.validateLocal(cleanNumber)) {
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

    final matches =
        countries.where((country) {
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
    return _countriesByCode[isoCode.toLowerCase()];
  }

  /// Gets a country by its name (case-insensitive).
  static CountryData? getCountryByName(String name) {
    return _countriesByName[name.toLowerCase()];
  }

  /// Gets all countries with a specific dial code.
  static List<CountryData> getCountriesByDialCode(String dialCode) {
    final normalized = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    return countries.where((c) => c.dialCode == normalized).toList();
  }
}
