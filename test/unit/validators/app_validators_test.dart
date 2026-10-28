import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/core/utils/app_validators.dart';

/// Test plan §1.5 — Validators used by the auth forms and the Edit Profile
/// screen (`AppValidators`).
void main() {
  group('§1.5 required text fields reject empty input', () {
    test('first / last name', () {
      expect(AppValidators.name(null), 'Name is required');
      expect(AppValidators.name(''), 'Name is required');
      expect(AppValidators.name('   '), 'Name is required');
      expect(AppValidators.name('Isthiyaque'), isNull);
    });

    test('a single-character name is rejected as too short', () {
      expect(AppValidators.name('I'), 'Name must be at least 2 characters');
      expect(AppValidators.name('Li'), isNull);
    });

    test('post applied for', () {
      expect(AppValidators.post(null), 'Post is required');
      expect(AppValidators.post(''), 'Post is required');
      expect(AppValidators.post('  '), 'Post is required');
      expect(AppValidators.post('E'), 'Post must be at least 2 characters');
      expect(AppValidators.post('Fourth Engineer'), isNull);
    });

    test('date of birth', () {
      expect(AppValidators.dob(null), 'Date of birth is required');
      expect(AppValidators.dob(''), 'Date of birth is required');
      expect(AppValidators.dob('   '), 'Date of birth is required');
      expect(AppValidators.dob('17/7/1987'), isNull);
    });

    test('nationality', () {
      expect(AppValidators.nationality(null), 'Nationality is required');
      expect(AppValidators.nationality(''), 'Nationality is required');
      expect(AppValidators.nationality('  '), 'Nationality is required');
      expect(AppValidators.nationality('Indian'), isNull);
    });

    test('the generic required validator names the offending field', () {
      expect(
        AppValidators.required(null, 'Passport number'),
        'Passport number is required',
      );
      expect(AppValidators.required('   ', 'Validity'), 'Validity is required');
      expect(AppValidators.required('P1234567', 'Passport number'), isNull);
    });
  });

  group('§1.5 email', () {
    test('is required', () {
      expect(AppValidators.email(null), 'Email is required');
      expect(AppValidators.email(''), 'Email is required');
      expect(AppValidators.email('   '), 'Email is required');
    });

    test('accepts ordinary addresses', () {
      for (final value in const [
        'seafarer@example.com',
        'first.last@example.co.in',
        'user-name@sub.example.org',
        'digits123@example.info',
      ]) {
        expect(AppValidators.email(value), isNull, reason: 'rejected $value');
      }
    });

    test('rejects malformed addresses', () {
      for (final value in const [
        'not-an-email',
        'missing@domain',
        '@example.com',
        'spaces in@example.com',
        'trailing@example.',
        'double@@example.com',
      ]) {
        expect(
          AppValidators.email(value),
          'Enter a valid email address',
          reason: 'accepted $value',
        );
      }
    });

    test('is stricter than RFC 5322 for plus-addressing and long TLDs', () {
      // Documents current behaviour rather than endorsing it: the regex allows
      // only word characters, `-` and `.` in the local part, and a 2-4
      // character final label. Widen the regex if seafarers report being
      // unable to sign up with these addresses.
      expect(
        AppValidators.email('user+tag@example.com'),
        'Enter a valid email address',
      );
      expect(
        AppValidators.email('captain@example.travel'),
        'Enter a valid email address',
      );
    });
  });

  group('§1.5 password', () {
    test('is required', () {
      expect(AppValidators.password(null), 'Password is required');
      expect(AppValidators.password(''), 'Password is required');
    });

    test('rejects passwords shorter than the advertised minimum', () {
      expect(
        AppValidators.password('short'),
        'Password must be at least 8 characters',
      );
    });

    test('accepts a password of exactly the advertised minimum length', () {
      // The message promises "at least 8 characters", so an 8-character
      // password must be accepted.
      expect(AppValidators.password('12345678'), isNull);
    });

    test('accepts a longer password', () {
      expect(AppValidators.password('password123'), isNull);
    });
  });

  group('§1.5 confirm password', () {
    test('is required', () {
      expect(AppValidators.confirmPassword(null, 'pw'), 'Password is required');
      expect(AppValidators.confirmPassword('', 'pw'), 'Password is required');
    });

    test('must match the password', () {
      expect(
        AppValidators.confirmPassword('other', 'password123'),
        'Password does not match',
      );
    });

    test('passes when both match', () {
      expect(AppValidators.confirmPassword('password123', 'password123'), isNull);
    });
  });

  group('§1.5 matchPattern', () {
    test('applies the supplied pattern and message', () {
      expect(
        AppValidators.matchPattern('48500', r'^\d+$', 'Numbers only'),
        isNull,
      );
      expect(
        AppValidators.matchPattern('48,500 t', r'^\d+$', 'Numbers only'),
        'Numbers only',
      );
      expect(
        AppValidators.matchPattern(null, r'^\d+$', 'Numbers only'),
        'Numbers only',
      );
    });
  });

  group('§1.5 date validators', () {
    test(
      'a malformed date of birth is rejected',
      () {
        // TDD — `AppValidators.dob` only checks for emptiness today, so
        // '32/13/2020' or 'abc' are accepted. Expected interface:
        //
        //   static String? dob(String? value)  // returns
        //   'Enter a valid date' for anything that is not a real dd/mm/yyyy
        //   date, on top of the existing required check.
        fail('AppValidators.dob does not validate the date format');
      },
      skip: 'Date-format validation is not implemented — see comment',
    );

    test(
      'a date of birth in the future is rejected',
      () {
        // TDD — expected: 'Date of birth cannot be in the future'.
        fail('AppValidators.dob does not reject future dates');
      },
      skip: 'Future-DOB validation is not implemented — see comment',
    );

    test(
      'a validity date must fall after the issue date',
      () {
        // TDD — applies to both Documents and Courses rows. Expected
        // interface:
        //
        //   static String? validityAfterIssue({
        //     required String? issueDate,
        //     required String? validity,
        //   });  // 'Validity must be after the date of issue'
        //
        // Today `DocumentWrapperWidget` / `CourseWrapperWidget` only apply
        // `AppValidators.required` to each date independently.
        fail('No cross-field date-order validator exists');
      },
      skip: 'Validity-after-issue validation is not implemented — see comment',
    );
  });

  group('§1.5 numeric fields', () {
    test(
      'G.R.T rejects non-numeric input',
      () {
        // TDD — the GRT/BHP fields in the Sea Experience sheet are plain text
        // inputs with no validator. Expected interface:
        //
        //   static String? numeric(String? value, String fieldName);
        //     // '<fieldName> must be a number'
        //
        // `AppValidators.matchPattern(value, r'^\d+$', ...)` already exists and
        // could back it — see the matchPattern group above.
        fail('No numeric validator is wired to the G.R.T field');
      },
      skip: 'Numeric validation is not implemented — see comment',
    );
  });
}
