import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/constants.dart';
import 'package:nocconsumer/main.dart';
import 'package:nocconsumer/model/User.dart';
import 'package:nocconsumer/services/FirebaseHelper.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/services/localDatabase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late User user;

  late CartDatabase cartDatabase;

  late bool pushNewMessages, orderUpdates, newArrivals, promotions;
  int cartCount = 0;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    pushNewMessages = user.settings.pushNewMessages;
    orderUpdates = user.settings.orderUpdates;
    newArrivals = user.settings.newArrivals;
    promotions = user.settings.promotions;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cartDatabase = Provider.of<CartDatabase>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: TextStyle(fontFamily : "GlacialIndifference",
            color: isDarkMode(context) ? Colors.white : Colors.black,
          ),
        ).tr(),
      ),
      body: SingleChildScrollView(
        child: Builder(
            builder: (buildContext) => Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 16, top: 16, bottom: 8),
                      child: Text(
                        'pushNotifications'.tr(),
                        style: TextStyle(fontFamily : "GlacialIndifference",color: isDarkMode(context) ? Colors.white54 : Colors.black54, fontSize: 18),
                      ).tr(),
                    ),
                    Material(
                      elevation: 2,
                      color: isDarkMode(context) ? Colors.black12 : Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SwitchListTile.adaptive(
                              activeColor: Color(0xFFFEDF00),
                              title: Text(
                                'allowPushNotifications'.tr(),
                                style: TextStyle(fontFamily : "GlacialIndifference",
                                  fontSize: 16,
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                ),
                              ).tr(),
                              value: pushNewMessages,
                              onChanged: (bool newValue) {
                                pushNewMessages = newValue;
                                setState(() {});
                              }                              ),
                          SwitchListTile.adaptive(
                              activeColor: Color(0xFFFEDF00),
                              title: Text(
                                'Order Updates'.tr(),
                                style: TextStyle(fontFamily : "GlacialIndifference",
                                  fontSize: 16,
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                ),
                              ).tr(),
                              value: orderUpdates,
                              onChanged: (bool newValue) {
                                orderUpdates = newValue;
                                setState(() {});
                              }),
                          // SwitchListTile.adaptive(
                          //     activeColor: Color(0xFFFEDF00),
                          //     title: Text(
                          //       'New Arrivals',
                          //       style: TextStyle(fontFamily : "GlacialIndifference",
                          //          fontSize: 16,
                          //         color: isDarkMode(context)
                          //             ? Colors.white
                          //             : Colors.black,
                          //       ),
                          //     ).tr(),
                          //     value: newArrivals,
                          //     onChanged: (bool newValue) {
                          //       newArrivals = newValue;
                          //       setState(() {});
                          //     }),
                          SwitchListTile.adaptive(
                              activeColor: Color(0xFFFEDF00),
                              title: Text(
                                'Promotions'.tr(),
                                style: TextStyle(fontFamily : "GlacialIndifference",
                                  fontSize: 16,
                                  color: isDarkMode(context) ? Colors.white : Colors.black,
                                ),
                              ).tr(),
                              value: promotions,
                              onChanged: (bool newValue) {
                                promotions = newValue;
                                setState(() {});
                              }),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 16 , right: 10, left: 10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: double.infinity),
                        child: Material(
                          elevation: 2,
                          color: isDarkMode(context) ? Colors.black12 : Colors.white,
                          child: CupertinoButton(
                            padding: const EdgeInsets.all(12.0),
                            onPressed: () async {
                              showProgress(context, 'savingChanges'.tr(), true);
                              user.settings.pushNewMessages = pushNewMessages;
                              user.settings.orderUpdates = orderUpdates;
                              user.settings.newArrivals = newArrivals;
                              user.settings.promotions = promotions;
                              User? updateUser = await FireStoreUtils.updateCurrentUser(user);
                              hideProgress();
                              if (updateUser != null) {
                                this.user = updateUser;
                                MyAppState.currentUser = user;
                                ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(
                                    duration: const Duration(seconds: 3),
                                    content: Text(
                                      'settingsSavedSuccessfully'.tr(),
                                      style: const TextStyle(fontFamily : "GlacialIndifference",fontSize: 17),
                                    ).tr()));
                              }
                            },
                            child: Text(
                              'save'.tr(),
                              style: TextStyle(fontFamily : "GlacialIndifference",fontSize: 18, color: Colors.black),
                            ).tr(),
                            color: Color(0xFFFEDF00),
                          ),
                        ),
                      ),
                    )
                  ],
                )),
      ),
    );
  }
}
