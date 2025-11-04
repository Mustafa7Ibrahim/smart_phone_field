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
      const country1 = CountryData(
        name: 'Test',
        code: 'TS',
        dialCode: '+999',
        flag: '🏳️',
        pattern: r'^999',
        localPatterns: [r'^[0-9]{10}$'],
      );
      const country2 = CountryData(
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
}
