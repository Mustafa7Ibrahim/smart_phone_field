import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../data/all_countries.dart';
import '../models/country_data.dart';

/// Utilities for validating and detecting phone numbers
/// Now powered by Google's libphonenumber via phone_numbers_parser
class PhoneValidator {
  // For faster lookups, we use maps to store countries by code and name.
  static final Map<String, CountryData> _countriesByCode = {
    for (var country in countries) country.code.toLowerCase(): country
  };

  static final Map<String, CountryData> _countriesByName = {
    for (var country in countries) country.name.toLowerCase(): country
  };

  /// Detects the country from a phone number using Google's libphonenumber.
  /// Returns the matching country or null if no match found.
  ///
  /// The phone number can be in any format (with or without +, spaces, dashes, etc.).
  /// This method uses libphonenumber for accurate country detection and falls back
  /// to custom pattern matching if parsing fails.
  ///
  /// Example:
  /// ```dart
  /// final country = PhoneValidator.detectCountry('+12025551234');
  /// // Returns United States
  ///
  /// final country2 = PhoneValidator.detectCountry('0101248831');
  /// // Returns Egypt (detected from local pattern)
  /// ```
  static CountryData? detectCountry(String phoneNumber) {
    if (phoneNumber.isEmpty) return null;

    try {
      // Try to parse with libphonenumber
      final parsedNumber = PhoneNumber.parse(phoneNumber);

      // Get the ISO code from the parsed number
      final isoCodeStr = parsedNumber.isoCode.name;

      // Find the matching country in our list
      return getCountryByCode(isoCodeStr);
    } catch (e) {
      // If parsing fails, fall back to custom pattern matching
      return _detectCountryWithCustomPatterns(phoneNumber);
    }
  }

  /// Detects country using custom pattern matching (fallback method).
  /// This is used when libphonenumber parsing fails.
  static CountryData? _detectCountryWithCustomPatterns(String phoneNumber) {
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
  ///
  /// Uses Google's libphonenumber for robust validation.
  static bool validateInternational(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    try {
      // Try to parse with libphonenumber
      final parsedNumber = PhoneNumber.parse(phoneNumber);
      return parsedNumber.isValid();
    } catch (e) {
      // If parsing fails, fall back to custom pattern matching
      final country = detectCountry(phoneNumber);
      if (country == null) return false;

      // Extract the local part after the dial code
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      final dialCodeDigits = country.dialCode.replaceAll('+', '');

      if (!cleanNumber.startsWith(dialCodeDigits)) return false;

      final localNumber = cleanNumber.substring(dialCodeDigits.length);
      return country.validateLocal(localNumber);
    }
  }

  /// Validates a local phone number for a specific country.
  /// Uses Google's libphonenumber for robust validation.
  static bool validateLocal(String localNumber, CountryData country) {
    if (localNumber.isEmpty) return false;

    try {
      // Try to parse with libphonenumber using country context
      final parsedNumber = PhoneNumber.parse(
        localNumber,
        callerCountry: IsoCode.fromJson(country.code),
      );
      return parsedNumber.isValid();
    } catch (e) {
      // If parsing fails, fall back to custom pattern matching
      return country.validateLocal(localNumber);
    }
  }

  /// Formats a phone number to international format (+XX XXX XXX XXXX).
  /// Uses Google's libphonenumber for proper country-specific formatting.
  static String formatInternational(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    try {
      // Try to parse and format with libphonenumber
      final parsedNumber = PhoneNumber.parse(phoneNumber);
      return parsedNumber.international;
    } catch (e) {
      // If parsing fails, fall back to basic formatting
      final country = detectCountry(phoneNumber);
      if (country == null) return phoneNumber;

      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      return '+$cleanNumber';
    }
  }

  /// Formats a phone number to national format.
  /// Uses Google's libphonenumber for proper country-specific formatting.
  static String formatNational(String phoneNumber, {CountryData? country}) {
    if (phoneNumber.isEmpty) return phoneNumber;

    try {
      // Try to parse and format with libphonenumber
      final parsedNumber = country != null
          ? PhoneNumber.parse(
              phoneNumber,
              callerCountry: IsoCode.fromJson(country.code),
            )
          : PhoneNumber.parse(phoneNumber);
      return parsedNumber.formatNsn();
    } catch (e) {
      // If parsing fails, return the original number
      return phoneNumber;
    }
  }

  /// Formats a phone number as the user types (E.164 format).
  /// Uses Google's libphonenumber for proper formatting.
  static String formatAsYouType(String phoneNumber, {CountryData? country}) {
    if (phoneNumber.isEmpty) return phoneNumber;

    try {
      // Try to parse and format with libphonenumber
      final parsedNumber = country != null
          ? PhoneNumber.parse(
              phoneNumber,
              callerCountry: IsoCode.fromJson(country.code),
            )
          : PhoneNumber.parse(phoneNumber);
      return parsedNumber.international;
    } catch (e) {
      // If parsing fails during typing, return the original input
      return phoneNumber;
    }
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

  /// Checks if a phone number is a valid mobile number.
  /// Uses Google's libphonenumber for accurate validation.
  static bool isMobileNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    try {
      final parsedNumber = PhoneNumber.parse(phoneNumber);
      return parsedNumber.isValid(type: PhoneNumberType.mobile);
    } catch (e) {
      return false;
    }
  }

  /// Checks if a phone number is a valid fixed line number.
  /// Uses Google's libphonenumber for accurate validation.
  static bool isFixedLineNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;

    try {
      final parsedNumber = PhoneNumber.parse(phoneNumber);
      return parsedNumber.isValid(type: PhoneNumberType.fixedLine);
    } catch (e) {
      return false;
    }
  }

  /// Validates a phone number for a specific type.
  /// Uses Google's libphonenumber for accurate type-specific validation.
  static bool validatePhoneNumberType(
    String phoneNumber,
    PhoneNumberType type,
  ) {
    if (phoneNumber.isEmpty) return false;

    try {
      final parsedNumber = PhoneNumber.parse(phoneNumber);
      return parsedNumber.isValid(type: type);
    } catch (e) {
      return false;
    }
  }
}
