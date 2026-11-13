import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:muggu_studio/app/app.dart';
import 'package:muggu_studio/core/localization/locale_controller.dart';

class _MemoryLocaleStorage implements LocaleStorage {
  String? languageCode;

  @override
  Future<String?> readLanguageCode() async => languageCode;

  @override
  Future<void> writeLanguageCode(String languageCode) async {
    this.languageCode = languageCode;
  }
}

void main() {
  testWidgets('all primary destinations are reachable', (tester) async {
    final storage = _MemoryLocaleStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeStorageProvider.overrideWithValue(storage),
          initialLocaleProvider.overrideWithValue(const Locale('en')),
        ],
        child: const MugguStudioApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Muggu Studio'), findsOneWidget);
    expect(find.text('Daily Muggu'), findsOneWidget);

    await tester.tap(find.text('Explore').last);
    await tester.pumpAndSettle();
    expect(find.text('Your design library is taking shape'), findsOneWidget);

    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();
    expect(find.text('Your creative space is coming'), findsOneWidget);

    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing saved yet'), findsOneWidget);

    await tester.tap(find.text('Home').last);
    await tester.pumpAndSettle();
    expect(find.text('Daily Muggu'), findsOneWidget);
  });

  testWidgets('language changes update the UI and persist', (tester) async {
    final storage = _MemoryLocaleStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeStorageProvider.overrideWithValue(storage),
          initialLocaleProvider.overrideWithValue(const Locale('en')),
        ],
        child: const MugguStudioApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Choose language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();

    expect(find.text('முக்கு ஸ்டுடியோ'), findsOneWidget);
    expect(storage.languageCode, 'ta');

    await tester.tap(find.byTooltip('மொழியைத் தேர்ந்தெடுக்கவும்'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('తెలుగు'));
    await tester.pumpAndSettle();

    expect(find.text('ముగ్గు స్టూడియో'), findsOneWidget);
    expect(find.text('నేటి ముగ్గు'), findsOneWidget);
    expect(storage.languageCode, 'te');
  });
}
