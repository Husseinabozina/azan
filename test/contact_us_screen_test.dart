import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/contact_us/contact_us_screen.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UrlLauncherPlatform originalUrlLauncher;
  late _FakeUrlLauncherPlatform fakeUrlLauncher;

  setUpAll(() {
    AppCubit.configure(dio: Dio());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    await CacheHelper.init();
    originalUrlLauncher = UrlLauncherPlatform.instance;
    fakeUrlLauncher = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakeUrlLauncher;
  });

  tearDown(() {
    UrlLauncherPlatform.instance = originalUrlLauncher;
  });

  Widget buildHarness(Widget child, {Size size = const Size(393, 852)}) {
    UiRotationCubit().changeIsLandscape(size.width > size.height);

    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('bn')],
      path: 'assets/Lang',
      assetLoader: const CodegenLoader(),
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: MediaQuery(
              data: MediaQueryData(size: size),
              child: MQScaleInit(
                designSize: size,
                minTextAdapt: true,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets('ContactUsScreen builds safely in portrait and landscape', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness(const ContactUsScreen()));
    await tester.pumpAndSettle();

    expect(find.text(LocaleKeys.contact_us.tr()), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      buildHarness(const ContactUsScreen(), size: const Size(1200, 800)),
    );
    await tester.pumpAndSettle();

    expect(find.text(LocaleKeys.contact_us.tr()), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ContactUsScreen validates empty message before launch', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness(const ContactUsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('contact-us-send-button')));
    await tester.pumpAndSettle();

    expect(find.text(LocaleKeys.contact_us_empty_error.tr()), findsOneWidget);
    expect(fakeUrlLauncher.lastLaunchedUrl, isNull);
  });

  testWidgets('ContactUsScreen builds the expected mailto payload', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness(const ContactUsScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('contact-us-message-field')),
      'هذه رسالة اختبار',
    );
    await tester.tap(find.byKey(const ValueKey('contact-us-send-button')));
    await tester.pumpAndSettle();

    expect(fakeUrlLauncher.lastLaunchedUrl, isNotNull);
    expect(
      fakeUrlLauncher.lastLaunchOptions?.mode,
      PreferredLaunchMode.externalApplication,
    );

    final uri = Uri.parse(fakeUrlLauncher.lastLaunchedUrl!);
    expect(uri.scheme, 'mailto');
    expect(uri.path, 'sajdh1447@gmail.com');
    expect(
      uri.queryParameters['subject'],
      LocaleKeys.contact_us_email_subject.tr(),
    );
    expect(uri.queryParameters['body'], 'هذه رسالة اختبار');
  });

  testWidgets('ContactUsScreen shows an error when no mail app is available', (
    tester,
  ) async {
    fakeUrlLauncher.launchSucceeds = false;

    await tester.pumpWidget(buildHarness(const ContactUsScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('contact-us-message-field')),
      'اقتراح جديد',
    );
    await tester.tap(find.byKey(const ValueKey('contact-us-send-button')));
    await tester.pumpAndSettle();

    expect(find.text(LocaleKeys.contact_us_launch_error.tr()), findsOneWidget);
  });

  testWidgets('CustomDrawer opens ContactUsScreen from the contact entry', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        Builder(
          builder: (context) {
            return Scaffold(
              drawer: CustomDrawer(context: context),
              body: Builder(
                builder: (innerContext) {
                  return Center(
                    child: TextButton(
                      onPressed: () => Scaffold.of(innerContext).openDrawer(),
                      child: const Text('Open drawer'),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open drawer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(LocaleKeys.contact_us.tr()).last);
    await tester.pumpAndSettle();

    expect(find.byType(ContactUsScreen), findsOneWidget);
  });
}

class _FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  String? lastLaunchedUrl;
  LaunchOptions? lastLaunchOptions;
  bool launchSucceeds = true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    lastLaunchedUrl = url;
    return launchSucceeds;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    lastLaunchOptions = options;
    return launchSucceeds;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;
}
