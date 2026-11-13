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
  testWidgets('home navigation and language selection work', (tester) async {
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

    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing saved yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Choose language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();

    expect(find.text('முக்கு ஸ்டுடியோ'), findsOneWidget);
    expect(find.text('இன்னும் எதுவும் சேமிக்கப்படவில்லை'), findsOneWidget);
    expect(storage.languageCode, 'ta');
  });
}
