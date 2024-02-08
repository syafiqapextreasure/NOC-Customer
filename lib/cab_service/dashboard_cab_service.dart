import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/AppGlobal.dart';
import 'package:nocconsumer/cab_service/cab_home_screen.dart';
import 'package:nocconsumer/cab_service/cab_order_screen.dart';
import 'package:nocconsumer/constants.dart';
import 'package:nocconsumer/main.dart';
import 'package:nocconsumer/model/User.dart';
import 'package:nocconsumer/services/FirebaseHelper.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/services/localDatabase.dart';
import 'package:nocconsumer/ui/CustomerSupport/CustomerSupport.dart';
import 'package:nocconsumer/ui/Language/language_choose_screen.dart';
import 'package:nocconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:nocconsumer/ui/auth/AuthScreen.dart';
import 'package:nocconsumer/ui/chat_screen/inbox_driver_screen.dart';
import 'package:nocconsumer/ui/privacy_policy/privacy_policy.dart';
import 'package:nocconsumer/ui/profile/ProfileScreen.dart';
import 'package:nocconsumer/ui/termsAndCondition/terms_and_codition.dart';
import 'package:nocconsumer/ui/wallet/walletScreen.dart';
import 'package:nocconsumer/userPrefrence.dart';
import 'package:nocconsumer/utils/DarkThemeProvider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum DrawerSelection { Dashboard, Home, Wallet, Profile, Orders, termsCondition, privacyPolicy, chooseLanguage, driver, customerSupport, Logout }

class DashBoardCabService extends StatefulWidget {
  final User? user;
  final Widget currentWidget;
  final String vendorId;
  final String appBarTitle;
  final DrawerSelection drawerSelection;

  DashBoardCabService({Key? key, required this.user, currentWidget, vendorId, appBarTitle, this.drawerSelection = DrawerSelection.Home})
      : appBarTitle = appBarTitle ?? 'Home'.tr(),
        vendorId = vendorId ?? "",
        currentWidget = currentWidget ??
            CabHomeScreen(
              user: MyAppState.currentUser,
            ),
        super(key: key);

  @override
  _DashBoardCabService createState() {
    return _DashBoardCabService();
  }
}

class _DashBoardCabService extends State<DashBoardCabService> {
  var key = GlobalKey<ScaffoldState>();

  late CartDatabase cartDatabase;
  late User user;
  late String _appBarTitle;
  final fireStoreUtils = FireStoreUtils();

  late Widget _currentWidget;
  late DrawerSelection _drawerSelection;

  int cartCount = 0;
  bool? isWalletEnable;

  @override
  void initState() {
    FireStoreUtils.getWalletSettingData();
    fireStoreUtils.getplaceholderimage().then((value) {
      AppGlobal.placeHolderImage = value;
    });

    super.initState();
    //FireStoreUtils.walletSettingData().then((value) => isWalletEnable = value);
    if (widget.user != null) {
      user = widget.user!;
    } else {
      user = User();
    }
    _currentWidget = widget.currentWidget;
    _appBarTitle = widget.appBarTitle;
    _drawerSelection = widget.drawerSelection;
    //getKeyHash();
    /// On iOS, we request notification permissions, Does nothing and returns null on Android
    FireStoreUtils.firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    getTaxList();
  }
  getTaxList() async{
    await FireStoreUtils().getTaxList(sectionConstantModel!.id).then((value) {
      if (value != null) {
        taxList = value;
      }
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }

  DateTime pre_backpress = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        if (_currentWidget is! CabHomeScreen) {
          setState(() {
            _drawerSelection = DrawerSelection.Home;
            _appBarTitle = 'Cab Ride'.tr();
            _currentWidget = CabHomeScreen(
              user: MyAppState.currentUser,
            );
          });
          return false;
        } else {
          pushAndRemoveUntil(context, const StoreSelection(), false);
          return true;
        }
      },
      child: ChangeNotifierProvider.value(
        value: user,
        child: Consumer<User>(
          builder: (context, user, _) {
            return Scaffold(
              extendBodyBehindAppBar: _drawerSelection == DrawerSelection.Wallet ? true : false,
              key: key,
              drawer: Drawer(
                child: Container(
                    color: isDarkMode(context) ? Colors.black : null,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              Consumer<User>(builder: (context, user, _) {
                                return SizedBox(
                                  height: 190,
                                  child: DrawerHeader(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            displayCircleImage(user.profilePictureURL, 60, false),
                                            Spacer(),
                                            Image.asset("assets/images/darklogo.png",height: 70,width: 70,),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 8,),
                                                  Text(
                                                    user.fullName(),
                                                    style: const TextStyle(fontFamily : "GlacialIndifference",color: Colors.black),
                                                  ),
                                                  Text(
                                                    user.email,
                                                    style: const TextStyle(fontFamily : "GlacialIndifference",color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                !themeChange.darkTheme ? const Icon(Icons.light_mode_sharp, color: Colors.black) : const Icon(Icons.nightlight, color: Colors.black),
                                                Switch(
                                                  // thumb color (round icon)
                                                  splashRadius: 50.0,
                                                  // activeThumbImage: const AssetImage('https://lists.gnu.org/archive/html/emacs-devel/2015-10/pngR9b4lzUy39.png'),
                                                  // inactiveThumbImage: const AssetImage('http://wolfrosch.com/_img/works/goodies/icon/vim@2x'),

                                                  value: themeChange.darkTheme,
                                                  onChanged: (value) => setState(() => themeChange.darkTheme = value),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFEDF00),
                                    ),
                                  ),
                                );                              }),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.white,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Dashboard,
                                  title:  Text('Dashboard',style: TextStyle( color: _drawerSelection == DrawerSelection.Dashboard
                                      ? Colors.white
                                  : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    pushAndRemoveUntil(context, const StoreSelection(), false);
                                  },
                                  leading: Image.asset(
                                    'assets/images/dashboard.png',
                                    color: _drawerSelection == DrawerSelection.Dashboard
                                        ? Colors.white
                                        : isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.yellow,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Home,
                                  title:  Text('Book Ride',style: TextStyle( color: _drawerSelection == DrawerSelection.Home
                                      ? Colors.yellow
                                      : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _drawerSelection = DrawerSelection.Home;
                                      _appBarTitle = 'Stores'.tr();
                                      _currentWidget = CabHomeScreen(
                                        user: MyAppState.currentUser,
                                      );
                                    });
                                  },
                                  leading: const Icon(CupertinoIcons.home),
                                ),
                              ),
                              Visibility(
                                visible: UserPreference.getWalletData() ?? false,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Colors.yellow,
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.Wallet,
                                    leading: const Icon(Icons.account_balance_wallet_outlined),
                                    title:  Text("Wallet",style: TextStyle( color: _drawerSelection == DrawerSelection.Wallet
                                        ? Colors.yellow
                                        : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      if (MyAppState.currentUser == null) {
                                        push(context, const AuthScreen());
                                      } else {
                                        setState(() {
                                          _drawerSelection = DrawerSelection.Wallet;
                                          _appBarTitle = 'Wallet'.tr();
                                          _currentWidget = const WalletScreen();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.yellow,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Profile,
                                  leading: const Icon(CupertinoIcons.person),
                                  title:  Text('Profile',style: TextStyle( color: _drawerSelection == DrawerSelection.Profile
                                      ? Colors.yellow
                                      : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection = DrawerSelection.Profile;
                                        _appBarTitle = 'My Profile'.tr();
                                        _currentWidget = const ProfileScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.yellow,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Orders,
                                  leading: Image.asset(
                                    'assets/images/truck.png',
                                    color: _drawerSelection == DrawerSelection.Orders
                                        ? Colors.yellow
                                        : isDarkMode(context)
                                            ? Colors.grey.shade200
                                            : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                  title:  Text('Rides',style: TextStyle( color: _drawerSelection == DrawerSelection.Orders
                                      ? Colors.yellow
                                      : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (MyAppState.currentUser == null) {
                                      push(context, const AuthScreen());
                                    } else {
                                      setState(() {
                                        _drawerSelection = DrawerSelection.Orders;
                                        _appBarTitle = 'Rides'.tr();
                                        _currentWidget = const CabOrderScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                child: ListTile(
                                  leading: Image.asset(
                                    'assets/images/rewards.png',
                                    color: isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                  title: Text('Reward').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _appBarTitle = 'Reward'.tr();
                                      launchUrl(Uri.parse('https://noc-global.com/rewards'));
                                    });
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                child: ListTile(
                                  leading: Image.asset(
                                    'assets/images/incentives.png',
                                    color: isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                  title: Text('Incentive').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _appBarTitle = 'Incentive'.tr();
                                      launchUrl(Uri.parse('https://noc-global.com/incentives'));
                                    });
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                child: ListTile(
                                  leading: Image.asset(
                                    'assets/images/tutorial_icon.png',
                                    color: isDarkMode(context)
                                        ? Colors.grey.shade200
                                        : Colors.grey.shade600,
                                    width: 24,
                                    height: 24,
                                  ),
                                  title: Text('Tutorial').tr(),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _appBarTitle = 'Tutorial'.tr();
                                      launchUrl(Uri.parse('https://noc-global.com/tutorial'));
                                    });
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.yellow,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.termsCondition,
                                  leading: const Icon(Icons.policy),
                                  title:  Text('Terms and Condition',style: TextStyle( color: _drawerSelection == DrawerSelection.termsCondition
                                      ? Colors.yellow
                                      : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                  onTap: () async {
                                    push(context, const TermsAndCondition());
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.yellow,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.privacyPolicy,
                                  leading: const Icon(Icons.privacy_tip),
                                  title:  Text('Privacy policy',style: TextStyle( color: _drawerSelection == DrawerSelection.privacyPolicy
                                      ? Colors.yellow
                                      : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                  onTap: () async {
                                    push(context, const PrivacyPolicyScreen());
                                  },
                                ),
                              ),
                              Visibility(
                                visible: isLanguageShown,
                                child: ListTileTheme(
                                  style: ListTileStyle.drawer,
                                  selectedColor: Colors.yellow,
                                  child: ListTile(
                                    selected: _drawerSelection == DrawerSelection.chooseLanguage,
                                    leading: Icon(
                                      Icons.language,
                                      color: _drawerSelection == DrawerSelection.chooseLanguage
                                          ? Colors.yellow
                                          : isDarkMode(context)
                                              ? Colors.grey.shade200
                                              : Colors.grey.shade600,
                                    ),
                                    title:  Text('Language',style: TextStyle( color: _drawerSelection == DrawerSelection.chooseLanguage
                                        ? Colors.yellow
                                        : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.chooseLanguage;
                                        _appBarTitle = 'Language'.tr();
                                        _currentWidget = LanguageChooseScreen(
                                          isContainer: true,
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.yellow,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.driver,
                                  leading: const Icon(CupertinoIcons.chat_bubble_2_fill),
                                  title:  Text('Driver Inbox',style: TextStyle( color: _drawerSelection == DrawerSelection.driver
                                      ? Colors.yellow
                                      : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, const AuthScreen());
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        _drawerSelection = DrawerSelection.driver;
                                        _appBarTitle = 'Driver Inbox'.tr();
                                        _currentWidget = const InboxDriverScreen();
                                      });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.yellow,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.customerSupport,
                                  leading: const Icon(Icons.support_agent),
                                  title: Text('Customer Support',style: TextStyle( color: _drawerSelection == DrawerSelection.customerSupport
                                      ? Colors.yellow
                                      : isDarkMode(context) ? Colors.white : Colors.black,),).tr(),
                                  onTap: () {
                                    if (MyAppState.currentUser == null) {
                                      Navigator.pop(context);
                                      push(context, const AuthScreen());
                                    } else {Navigator.pop(context);
                                    setState(() {
                                      _drawerSelection = DrawerSelection.customerSupport;
                                      _appBarTitle = 'Customer Support'.tr();
                                      _currentWidget = CustomerSupport();
                                    });
                                    }
                                  },
                                ),
                              ),
                              ListTileTheme(
                                style: ListTileStyle.drawer,
                                selectedColor: Colors.yellow,
                                child: ListTile(
                                  selected: _drawerSelection == DrawerSelection.Logout,
                                  leading: const Icon(Icons.logout),
                                  title: Text((MyAppState.currentUser == null) ? 'Log In'.tr() : 'Log Out'.tr(),style: TextStyle( color: _drawerSelection == DrawerSelection.Logout
                                      ? Colors.yellow
                                      : isDarkMode(context) ? Colors.white : Colors.black,),),
                                  onTap: () async {
                                    if (MyAppState.currentUser == null) {
                                      pushAndRemoveUntil(context, const AuthScreen(), false);
                                    } else {
                                      Navigator.pop(context);
                                      //user.active = false;
                                      user.lastOnlineTimestamp = Timestamp.now();
                                      user.fcmToken = "";
                                      await FireStoreUtils.updateCurrentUser(user);
                                      await auth.FirebaseAuth.instance.signOut();
                                      MyAppState.currentUser = null;
                                      MyAppState.selectedPosition = Position.fromMap({'latitude': 0.0, 'longitude': 0.0,
                                        'timestamp': DateTime.now().microsecondsSinceEpoch});
                                      Provider.of<CartDatabase>(context, listen: false).deleteAllProducts();
                                      pushAndRemoveUntil(context, const AuthScreen(), false);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("V : $appVersion"),
                        )
                      ],
                    )),
              ),
              appBar: _drawerSelection == DrawerSelection.Home?null:AppBar(
                elevation: _drawerSelection == DrawerSelection.Wallet ? 0 : 0,
                centerTitle: _drawerSelection == DrawerSelection.Wallet ? true : false,
                backgroundColor: _drawerSelection == DrawerSelection.Wallet
                    ? Colors.transparent
                    : isDarkMode(context)
                        ? Colors.black
                        : Colors.white,
                //isDarkMode(context) ? Color(DARK_COLOR) : null,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: () {
                      key.currentState!.openDrawer();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      primary: Colors.white,
                      padding: const EdgeInsets.all(10),
                    ),
                    child: Image.asset(
                      "assets/icons/ic_side_menu.png",
                      color: Colors.black,
                    ),
                  ),
                ),
                // iconTheme: IconThemeData(color: Colors.blue),
                title: Text(
                  _appBarTitle,
                  style: TextStyle(fontFamily : "GlacialIndifference",
                            fontSize: 18,
                      color: _drawerSelection == DrawerSelection.Wallet
                          ? Colors.white
                          : isDarkMode(context)
                              ? Colors.white
                              : Colors.black,
                      //isDarkMode(context) ? Colors.white : Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ),
              body: _currentWidget,
            );
          },
        ),
      ),
    );
  }
}
