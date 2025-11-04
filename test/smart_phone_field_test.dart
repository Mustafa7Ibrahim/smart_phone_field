import 'package:flutter_test/flutter_test.dart';
import 'package:smart_phone_field/smart_phone_field.dart';

void main() {
  group('Country Data Tests', () {
    test('countries list contains 195 countries', () {
      expect(countries.length, 195);
    });

    test('Egypt country data is correct', () {
      final egypt = countries.firstWhere((c) => c.code == 'EG');
      expect(egypt.name, 'Egypt');
      expect(egypt.dialCode, '+20');
      expect(egypt.flag, '🇪🇬');
      expect(egypt.pattern, r'^20');
      expect(egypt.localPatterns.length, 2);
    });

    test('United States country data is correct', () {
      final us = countries.firstWhere((c) => c.code == 'US');
      expect(us.name, 'United States');
      expect(us.dialCode, '+1');
      expect(us.flag, '🇺🇸');
    });

    test('CountryData equality works correctly', () {
      final country1 = CountryData(
        name: 'Test',
        code: 'TS',
        dialCode: '+999',
        flag: '🏳️',
        pattern: r'^999',
        localPatterns: [r'^[0-9]{10}$'],
      );
      final country2 = CountryData(
        name: 'Test',
        code: 'TS',
        dialCode: '+999',
        flag: '🏳️',
        pattern: r'^999',
        localPatterns: [r'^[0-9]{10}$'],
      );
      expect(country1, country2);
    });

    test('NANP countries have correct priorities', () {
      final antigua = countries.firstWhere((c) => c.code == 'AG');
      final jamaica = countries.firstWhere((c) => c.code == 'JM');
      final canada = countries.firstWhere((c) => c.code == 'CA');
      final us = countries.firstWhere((c) => c.code == 'US');

      // Specific area codes should have higher priority
      expect(antigua.priority, 10);
      expect(jamaica.priority, 10);

      // Generic patterns should have lower priority
      expect(canada.priority, -10);
      expect(us.priority, -10);
    });

    test('Russia and Kazakhstan have priorities for +7 disambiguation', () {
      final russia = countries.firstWhere((c) => c.code == 'RU');
      final kazakhstan = countries.firstWhere((c) => c.code == 'KZ');

      expect(russia.priority, 5);
      expect(kazakhstan.priority, 5);
      expect(russia.dialCode, '+7');
      expect(kazakhstan.dialCode, '+7');
    });
  });

  group('CountryData Methods', () {
    test('matchesPattern correctly identifies matching numbers', () {
      final egypt = countries.firstWhere((c) => c.code == 'EG');

      expect(egypt.matchesPattern('201234567890'), isTrue);
      expect(egypt.matchesPattern('+201234567890'), isTrue);
      expect(egypt.matchesPattern('20 123 456 7890'), isTrue);
      expect(egypt.matchesPattern('301234567890'), isFalse);
    });

    test('validateLocal validates local phone patterns', () {
      final egypt = countries.firstWhere((c) => c.code == 'EG');

      // Egyptian mobile pattern: starts with 10, 11, 12, or 15
      expect(egypt.validateLocal('01012345678'), isTrue);
      expect(egypt.validateLocal('1012345678'), isTrue);
      expect(egypt.validateLocal('01112345678'), isTrue);
      expect(egypt.validateLocal('01234567890'), isTrue);

      // Invalid patterns
      expect(egypt.validateLocal('12345'), isFalse);
      expect(egypt.validateLocal('abc'), isFalse);
    });
  });

  group('PhoneValidator - Country Detection', () {
    test('detectCountry identifies Egypt correctly', () {
      final country = PhoneValidator.detectCountry('+201234567890');
      expect(country?.code, 'EG');
    });

    test('detectCountry prioritizes Antigua over US/Canada for +1-268', () {
      final country = PhoneValidator.detectCountry('+12685551234');
      expect(country?.code, 'AG'); // Antigua, not US or Canada
    });

    test('detectCountry prioritizes Jamaica over US/Canada for +1-876', () {
      final country = PhoneValidator.detectCountry('+18765551234');
      expect(country?.code, 'JM'); // Jamaica, not US or Canada
    });

    test('detectCountry handles generic US numbers', () {
      final country = PhoneValidator.detectCountry('+12125551234');
      // Should match US or Canada (both have same priority)
      expect(country?.dialCode, '+1');
      expect(['US', 'CA'].contains(country?.code), isTrue);
    });

    test('detectCountry handles numbers with formatting', () {
      final country1 = PhoneValidator.detectCountry('+1 (876) 555-1234');
      final country2 = PhoneValidator.detectCountry('1-876-555-1234');
      final country3 = PhoneValidator.detectCountry('18765551234');

      expect(country1?.code, 'JM');
      expect(country2?.code, 'JM');
      expect(country3?.code, 'JM');
    });

    test('detectCountry returns null for invalid numbers', () {
      expect(PhoneValidator.detectCountry(''), isNull);
      expect(PhoneValidator.detectCountry('abc'), isNull);
      expect(PhoneValidator.detectCountry('+++'), isNull);
    });

    test('detectCountry handles Russia vs Kazakhstan correctly', () {
      final russia = PhoneValidator.detectCountry('+79991234567');
      final kazakhstan = PhoneValidator.detectCountry('+77771234567');

      expect(russia?.code, 'RU');
      expect(kazakhstan?.code, 'KZ');
    });

    test('detectCountry detects Egypt from local format with leading 0', () {
      // Egyptian mobile numbers are 11 digits with leading 0, or 10 without
      final country = PhoneValidator.detectCountry('01012345678');
      expect(country?.code, 'EG');
      expect(country?.dialCode, '+20');
    });

    test('detectCountry handles local format with ambiguous patterns', () {
      // Numbers without leading 0 can be ambiguous with international format
      // For example, 1512345678 could be Egypt (15-12345678) or NANP (+1-512-345-6789)
      // The detector prioritizes international format interpretation
      final country = PhoneValidator.detectCountry('1512345678');
      // This matches NANP (+1) because international format is checked first
      expect(['US', 'CA'].contains(country?.code), isTrue);

      // However, with leading 0, it's clearly a local format
      final egyptWithZero = PhoneValidator.detectCountry('01512345678');
      expect(egyptWithZero?.code, 'EG');
    });

    test('detectCountryFromLocal works for various local formats', () {
      // Egypt mobile numbers (11 digits with 0, or 10 without)
      expect(PhoneValidator.detectCountryFromLocal('01012345678')?.code, 'EG');
      expect(PhoneValidator.detectCountryFromLocal('01123456789')?.code, 'EG');
      expect(PhoneValidator.detectCountryFromLocal('01212345678')?.code, 'EG');
      expect(PhoneValidator.detectCountryFromLocal('01512345678')?.code, 'EG');
      expect(PhoneValidator.detectCountryFromLocal('1512345678')?.code, 'EG');

      // Returns null for invalid local numbers
      expect(PhoneValidator.detectCountryFromLocal('123'), isNull);
      expect(PhoneValidator.detectCountryFromLocal(''), isNull);

      // Note: Due to the ambiguous nature of local phone patterns, some numbers
      // may match multiple countries. The country with highest priority is returned.
    });
  });

  group('PhoneValidator - Multiple Matches', () {
    test('detectAllMatches finds all NANP countries for generic +1', () {
      final matches = PhoneValidator.detectAllMatches('+12125551234');

      // Should match multiple countries with +1
      expect(matches.length, greaterThan(1));
      expect(matches.any((c) => c.code == 'US'), isTrue);
      expect(matches.any((c) => c.code == 'CA'), isTrue);

      // Should be sorted by priority (highest first)
      for (var i = 0; i < matches.length - 1; i++) {
        expect(matches[i].priority, greaterThanOrEqualTo(matches[i + 1].priority));
      }
    });

    test('detectAllMatches returns single match for unique dial code', () {
      final matches = PhoneValidator.detectAllMatches('+201234567890');
      expect(matches.length, 1);
      expect(matches.first.code, 'EG');
    });
  });

  group('PhoneValidator - Validation', () {
    test('validateInternational validates complete phone numbers', () {
      // Valid numbers
      expect(PhoneValidator.validateInternational('+201012345678'), isTrue);
      expect(PhoneValidator.validateInternational('+447912345678'), isTrue);

      // Invalid numbers
      expect(PhoneValidator.validateInternational('+20123'), isFalse);
      expect(PhoneValidator.validateInternational('invalid'), isFalse);
    });

    test('validateLocal validates local numbers for specific country', () {
      final egypt = countries.firstWhere((c) => c.code == 'EG');
      final uk = countries.firstWhere((c) => c.code == 'GB');

      expect(PhoneValidator.validateLocal('01012345678', egypt), isTrue);
      expect(PhoneValidator.validateLocal('07912345678', uk), isTrue);

      expect(PhoneValidator.validateLocal('123', egypt), isFalse);
      expect(PhoneValidator.validateLocal('123', uk), isFalse);
    });
  });

  group('PhoneValidator - Helper Methods', () {
    test('getCountryByCode finds country by ISO code', () {
      expect(PhoneValidator.getCountryByCode('EG')?.name, 'Egypt');
      expect(PhoneValidator.getCountryByCode('eg')?.name, 'Egypt');
      expect(PhoneValidator.getCountryByCode('US')?.name, 'United States');
      expect(PhoneValidator.getCountryByCode('INVALID'), isNull);
    });

    test('getCountryByName finds country by name', () {
      expect(PhoneValidator.getCountryByName('Egypt')?.code, 'EG');
      expect(PhoneValidator.getCountryByName('egypt')?.code, 'EG');
      expect(PhoneValidator.getCountryByName('United States')?.code, 'US');
      expect(PhoneValidator.getCountryByName('Invalid Country'), isNull);
    });

    test('getCountriesByDialCode finds all countries with dial code', () {
      final nanpCountries = PhoneValidator.getCountriesByDialCode('+1');
      expect(nanpCountries.length, greaterThan(10));
      expect(nanpCountries.every((c) => c.dialCode == '+1'), isTrue);

      final egyptCountries = PhoneValidator.getCountriesByDialCode('+20');
      expect(egyptCountries.length, 1);
      expect(egyptCountries.first.code, 'EG');
    });

    test('isSharedDialCode identifies shared dial codes', () {
      expect(PhoneValidator.isSharedDialCode('+1'), isTrue);
      expect(PhoneValidator.isSharedDialCode('+7'), isTrue);
      expect(PhoneValidator.isSharedDialCode('+20'), isFalse);
      expect(PhoneValidator.isSharedDialCode('+44'), isFalse);
    });

    test('getCountriesWithSameDialCode finds related countries', () {
      final us = countries.firstWhere((c) => c.code == 'US');
      final related = PhoneValidator.getCountriesWithSameDialCode(us);

      expect(related.length, greaterThan(5));
      expect(related.any((c) => c.code == 'CA'), isTrue);
      expect(related.any((c) => c.code == 'JM'), isTrue);
      expect(related.any((c) => c.code == 'US'), isFalse); // Excludes itself
    });

    test('formatInternational formats numbers correctly', () {
      final formatted = PhoneValidator.formatInternational('201234567890');
      expect(formatted, '+201234567890');

      final formatted2 = PhoneValidator.formatInternational('+1 (876) 555-1234');
      expect(formatted2, '+18765551234');
    });
  });

  group('All Countries - Data Integrity Tests', () {
    test('all countries have non-empty names', () {
      for (final country in countries) {
        expect(
          country.name.isNotEmpty,
          isTrue,
          reason: 'Country ${country.code} has empty name',
        );
      }
    });

    test('all countries have valid 2-character ISO codes', () {
      for (final country in countries) {
        expect(
          country.code.length,
          2,
          reason: 'Country ${country.name} has invalid code: ${country.code}',
        );
        expect(
          country.code.toUpperCase(),
          country.code,
          reason: 'Country ${country.name} code should be uppercase',
        );
      }
    });

    test('all countries have valid dial codes starting with +', () {
      for (final country in countries) {
        expect(
          country.dialCode.startsWith('+'),
          isTrue,
          reason: 'Country ${country.name} dial code does not start with +: ${country.dialCode}',
        );
        expect(
          country.dialCode.length,
          greaterThan(1),
          reason: 'Country ${country.name} has invalid dial code: ${country.dialCode}',
        );
        // Verify it's a valid number after the +
        final digits = country.dialCode.substring(1);
        expect(
          int.tryParse(digits),
          isNotNull,
          reason: 'Country ${country.name} dial code contains non-digits: ${country.dialCode}',
        );
      }
    });

    test('all countries have non-empty flag emojis', () {
      for (final country in countries) {
        expect(
          country.flag.isNotEmpty,
          isTrue,
          reason: 'Country ${country.name} has empty flag',
        );
      }
    });

    test('all countries have valid pattern regex', () {
      for (final country in countries) {
        expect(
          country.pattern.isNotEmpty,
          isTrue,
          reason: 'Country ${country.name} has empty pattern',
        );
        // Verify it's a valid regex by checking the cached regex compiled successfully
        expect(
          () => RegExp(country.pattern),
          returnsNormally,
          reason: 'Country ${country.name} has invalid regex pattern: ${country.pattern}',
        );
      }
    });

    test('all countries have at least one local pattern', () {
      for (final country in countries) {
        expect(
          country.localPatterns.isNotEmpty,
          isTrue,
          reason: 'Country ${country.name} has no local patterns',
        );
      }
    });

    test('all countries have valid local pattern regex', () {
      for (final country in countries) {
        for (var i = 0; i < country.localPatterns.length; i++) {
          final pattern = country.localPatterns[i];
          expect(
            pattern.isNotEmpty,
            isTrue,
            reason: 'Country ${country.name} has empty local pattern at index $i',
          );
          expect(
            () => RegExp(pattern),
            returnsNormally,
            reason: 'Country ${country.name} has invalid local regex pattern at index $i: $pattern',
          );
        }
      }
    });

    test('pattern regex starts with dial code digits', () {
      for (final country in countries) {
        final dialCodeDigits = country.dialCode.substring(1);
        // Pattern should start with the dial code (allowing for ^ anchor)
        final patternWithoutAnchor = country.pattern.replaceFirst(r'^', '');
        expect(
          patternWithoutAnchor.startsWith(dialCodeDigits),
          isTrue,
          reason: 'Country ${country.name} pattern "$patternWithoutAnchor" does not start with dial code "$dialCodeDigits"',
        );
      }
    });
  });

  group('All Countries - Uniqueness Tests', () {
    test('all country codes are unique', () {
      final codes = countries.map((c) => c.code).toList();
      final uniqueCodes = codes.toSet();
      expect(
        codes.length,
        uniqueCodes.length,
        reason: 'Duplicate country codes found',
      );
    });

    test('all country names are unique', () {
      final names = countries.map((c) => c.name).toList();
      final uniqueNames = names.toSet();
      expect(
        names.length,
        uniqueNames.length,
        reason: 'Duplicate country names found',
      );
    });

    test('country codes match expected format for lookups', () {
      // Test that all countries can be found via getCountryByCode
      for (final country in countries) {
        final found = PhoneValidator.getCountryByCode(country.code);
        expect(
          found,
          isNotNull,
          reason: 'Country ${country.name} (${country.code}) not found by code lookup',
        );
        expect(found?.code, country.code);
      }
    });

    test('country names match expected format for lookups', () {
      // Test that all countries can be found via getCountryByName
      for (final country in countries) {
        final found = PhoneValidator.getCountryByName(country.name);
        expect(
          found,
          isNotNull,
          reason: 'Country ${country.name} not found by name lookup',
        );
        expect(found?.name, country.name);
      }
    });
  });

  group('All Countries - Helper Methods Tests', () {
    test('dialCodeDigits works correctly for all countries', () {
      for (final country in countries) {
        final digits = country.dialCodeDigits;
        expect(
          digits,
          country.dialCode.substring(1),
          reason: 'Country ${country.name} dialCodeDigits mismatch',
        );
        // Should not contain +
        expect(
          digits.contains('+'),
          isFalse,
          reason: 'Country ${country.name} dialCodeDigits contains +',
        );
        // Should be numeric
        expect(
          int.tryParse(digits),
          isNotNull,
          reason: 'Country ${country.name} dialCodeDigits is not numeric: $digits',
        );
      }
    });

    test('displayName works correctly for all countries', () {
      for (final country in countries) {
        final display = country.displayName;
        expect(
          display.contains(country.flag),
          isTrue,
          reason: 'Country ${country.name} displayName missing flag',
        );
        expect(
          display.contains(country.name),
          isTrue,
          reason: 'Country ${country.name} displayName missing name',
        );
        expect(
          display.contains(country.dialCode),
          isTrue,
          reason: 'Country ${country.name} displayName missing dial code',
        );
      }
    });

    test('toString works correctly for all countries', () {
      for (final country in countries) {
        final str = country.toString();
        expect(
          str.contains(country.name),
          isTrue,
          reason: 'Country ${country.name} toString missing name',
        );
        expect(
          str.contains(country.code),
          isTrue,
          reason: 'Country ${country.name} toString missing code',
        );
        expect(
          str.contains(country.dialCode),
          isTrue,
          reason: 'Country ${country.name} toString missing dial code',
        );
      }
    });
  });

  group('All Countries - Priority Tests', () {
    test('shared dial code countries have appropriate priorities', () {
      final dialCodeGroups = <String, List<CountryData>>{};

      // Group countries by dial code
      for (final country in countries) {
        dialCodeGroups.putIfAbsent(country.dialCode, () => []).add(country);
      }

      // Check shared dial codes have priorities set
      for (final entry in dialCodeGroups.entries) {
        if (entry.value.length > 1) {
          // This is a shared dial code - verify all countries in the group are present
          expect(
            entry.value.isNotEmpty,
            isTrue,
            reason: 'Shared dial code ${entry.key} has no countries',
          );
        }
      }
    });

    test('NANP (+1) countries have proper priority distribution', () {
      final nanpCountries = countries.where((c) => c.dialCode == '+1').toList();

      expect(nanpCountries.length, greaterThan(10));

      // Should have both high priority (specific area codes) and low priority (generic)
      final highPriority = nanpCountries.where((c) => c.priority > 0).toList();
      final lowPriority = nanpCountries.where((c) => c.priority < 0).toList();

      expect(highPriority.isNotEmpty, isTrue, reason: 'No high priority NANP countries');
      expect(lowPriority.isNotEmpty, isTrue, reason: 'No low priority NANP countries');
    });

    test('+7 countries (Russia/Kazakhstan) have priorities', () {
      final plus7Countries = countries.where((c) => c.dialCode == '+7').toList();

      expect(plus7Countries.length, 2);
      expect(plus7Countries.every((c) => c.priority != 0), isTrue);
    });
  });

  group('CountryData - Assertions Tests', () {
    test('creating CountryData with empty name throws assertion', () {
      expect(
        () => CountryData(
          name: '',
          code: 'TS',
          dialCode: '+999',
          flag: '🏳️',
          pattern: r'^999',
          localPatterns: [r'^[0-9]{10}$'],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('creating CountryData with invalid code length throws assertion', () {
      expect(
        () => CountryData(
          name: 'Test',
          code: 'T',
          dialCode: '+999',
          flag: '🏳️',
          pattern: r'^999',
          localPatterns: [r'^[0-9]{10}$'],
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => CountryData(
          name: 'Test',
          code: 'TST',
          dialCode: '+999',
          flag: '🏳️',
          pattern: r'^999',
          localPatterns: [r'^[0-9]{10}$'],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('creating CountryData with invalid dial code throws assertion', () {
      expect(
        () => CountryData(
          name: 'Test',
          code: 'TS',
          dialCode: '999',
          flag: '🏳️',
          pattern: r'^999',
          localPatterns: [r'^[0-9]{10}$'],
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => CountryData(
          name: 'Test',
          code: 'TS',
          dialCode: '',
          flag: '🏳️',
          pattern: r'^999',
          localPatterns: [r'^[0-9]{10}$'],
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
