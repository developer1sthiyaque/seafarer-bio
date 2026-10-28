import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seafarer_bio_data/features/personal_details/domain/entities/sea_experience_controller_wrapper.dart';
import 'package:seafarer_bio_data/features/personal_details/presentation/view/edit_details.dart';
import 'package:seafarer_bio_data/widgets/not_found_widget.dart';

import '../../helpers/pump_app.dart';

/// Regression tests for two layout overflows found while writing the §2.2/§2.3
/// widget tests. Both reproduce at ordinary phone sizes, so they are asserted
/// here rather than worked around silently in the screen tests.
void main() {
  // iPhone 14/15 logical size — the most common phone class for this app.
  const phone = Size(390, 844);

  group('SeaExperienceWidget', () {
    testWidgets('does not overflow on a phone-width screen', (tester) async {
      // Overflows by ~73px at 390 wide and ~33px at 430 wide; it needs roughly
      // 463 logical pixels. Cause: the Type/Rank and From/To `Row`s put two
      // unconstrained `Column`s side by side with no `Expanded`/`Flexible`, so
      // long values such as "Bulk Carrier" + "Third Engineer" cannot shrink.
      useMobileSurface(tester, size: phone);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SeaExperienceWidget(
              seaExperienceControllerWrapper: SeaExperienceControllerWrapper(
                vesselName: 'MV Ocean Pioneer',
                company: 'Blue Horizon Shipping',
                vesselType: 'Bulk Carrier',
                grt: '48500',
                bhp: '12000',
                rank: 'Third Engineer',
                fromDate: '1.4.2021',
                toDate: '1.12.2021',
                period: '8',
              ),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
    });
  });

  group('NotFoundWidget', () {
    testWidgets('does not overflow on a phone-height screen', (tester) async {
      // Overflows by ~4px at 844 tall and ~24px at 600 tall. Cause: the
      // container is a fixed 15% of screen height, which is less than the
      // intrinsic height of its title + 16px gap + wrapped description.
      useMobileSurface(tester, size: phone);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NotFoundWidget(
              title: 'Not Found',
              desc: 'No Sea Experience, please add your experience '
                  'by clicking add button',
            ),
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
    });
  });
}
