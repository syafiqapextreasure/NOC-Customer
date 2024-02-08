import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/constants.dart';
import 'package:nocconsumer/model/CurrencyModel.dart';
import 'package:nocconsumer/model/mail_setting.dart';
import 'package:nocconsumer/services/FirebaseHelper.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/services/localDatabase.dart';
import 'package:nocconsumer/services/notification_service.dart';
import 'package:nocconsumer/ui/SplashScreen/splash.dart';
import 'package:nocconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:nocconsumer/ui/auth/AuthScreen.dart';
import 'package:nocconsumer/ui/onBoarding/OnBoardingScreen.dart';
import 'package:nocconsumer/userPrefrence.dart';
import 'package:nocconsumer/utils/Styles.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/User.dart';
import 'utils/DarkThemeProvider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await UserPreference.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<CartDatabase>(
          create: (_) => CartDatabase(),
        )
      ],
      child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ms')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          saveLocale: false,
          useOnlyLangCode: true,
          useFallbackTranslations: true,
          child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static User? currentUser;
  static Position selectedPosition = Position.fromMap({
    'latitude': 0.0,
    'longitude': 0.0,
    'timestamp': DateTime.now().microsecondsSinceEpoch
  });

  //  late Stream<StripeKeyModel> futureStirpe;
  //  String? data,d;

  // Define an async function to initialize FlutterFire
  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      String token = await NotificationService.getToken();
      log(":::::::TOKEN:::::: $token");
      if (currentUser != null) {
        await FireStoreUtils.getCurrentUser(currentUser!.userID).then((value) {
          if (value != null) {
            currentUser = value;
            currentUser!.fcmToken = token;
            FireStoreUtils.updateCurrentUser(currentUser!);
          }
        });
      }
    });
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        originalOnError!(errorDetails);
        // Forward to original handler.
      };
      // FirebaseFirestore.instance.collection(Setting).doc("globalSettings").get().then((dineinresult) {
      //   if (dineinresult.exists && dineinresult.data() != null && dineinresult.data()!.containsKey("website_color")) {
      //     0xFFFEDF00 = int.parse(dineinresult.data()!["website_color"].replaceFirst("#", "0xff"));
      //   }
      // });
      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("emailSetting")
          .get()
          .then((value) {
        if (value.exists) {
          mailSettings = MailSettings.fromJson(value.data()!);
        }
      });
      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("Version")
          .get()
          .then((value) {
        print(value.data());
        appVersion = value.data()!['app_version'].toString();
      });

      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("googleMapKey")
          .get()
          .then((value) {
        print(value.data());
        GOOGLE_API_KEY = value.data()!['key'].toString();
      });

      await FirebaseFirestore.instance
          .collection(Setting)
          .doc("serverKey")
          .get()
          .then((value) {
        print(value.data());
        SERVER_KEY = value.data()!['serverKey'].toString();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
              navigatorKey: notificationService.navigatorKey,
              localizationsDelegates: context.localizationDelegates,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              debugShowCheckedModeBanner: false,
              theme: Styles.themeData(themeChangeProvider.darkTheme, context),
              builder: EasyLoading.init(),
              home: const Splash()
              // OnBoarding()
              );
        },
      ),
    );
  }

  late StreamSubscription eventBusStream;

  @override
  void initState() {
    notificationInit();
    initializeFlutterFire();
    WidgetsBinding.instance.addObserver(this);
    getCurrentAppTheme();

    super.initState();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}
}

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  late Future<List<CurrencyModel>> futureCurrency;

  Future hasFinishedOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool finishedOnBoarding = (prefs.getBool(FINISHED_ON_BOARDING) ?? false);

    if (finishedOnBoarding) {
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        User? user = await FireStoreUtils.getCurrentUser(firebaseUser.uid);
        if (user != null && user.role == USER_ROLE_CUSTOMER) {
          if (user.active) {
            user.active = true;
            user.role = USER_ROLE_CUSTOMER;
            user.fcmToken =
                await FireStoreUtils.firebaseMessaging.getToken() ?? '';
            await FireStoreUtils.updateCurrentUser(user);
            MyAppState.currentUser = user;
            isSkipLogin = false;
            pushReplacement(context, const StoreSelection());
          } else {
            user.lastOnlineTimestamp = Timestamp.now();
            user.fcmToken = "";
            await FireStoreUtils.updateCurrentUser(user);
            await auth.FirebaseAuth.instance.signOut();
            MyAppState.currentUser = null;
            pushReplacement(context, const AuthScreen());
          }

          //UserPreference.setUserId(userID: user.userID);
          //
        } else {
          pushReplacement(context, const AuthScreen());
        }
      } else {
        pushReplacement(context, const AuthScreen());
      }
    } else {
      pushReplacement(context, const OnBoardingScreen());
    }
  }

  @override
  void initState() {
    super.initState();

    hasFinishedOnBoarding();
    // futureCurrency= FireStoreUtils().getCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation(Color(0xFFFEDF00)),
        ),
      ),
    );
  }
}
