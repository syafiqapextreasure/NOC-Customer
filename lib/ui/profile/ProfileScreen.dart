import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/constants.dart';
import 'package:nocconsumer/main.dart';
import 'package:nocconsumer/services/FirebaseHelper.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/ui/accountDetails/AccountDetailsScreen.dart';
import 'package:nocconsumer/ui/auth/AuthScreen.dart';
import 'package:nocconsumer/ui/contactUs/ContactUsScreen.dart';
import 'package:nocconsumer/ui/reauthScreen/reauth_user_screen.dart';
import 'package:nocconsumer/ui/settings/SettingsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? Colors.black : null,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 32, right: 32),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Center(child: displayCircleImage(MyAppState.currentUser!.profilePictureURL, 130, false)),
                // Positioned.directional(
                //   textDirection: Directionality.of(context),
                //   start: 80,
                //   end: 0,
                //   child: FloatingActionButton(
                //       backgroundColor: const Color(0xFFFEDF00),
                //       child: Icon(
                //         Icons.camera_alt,
                //         color: isDarkMode(context) ? Colors.white : Colors.black,
                //       ),
                //       mini: true,
                //       onPressed: _onCameraClick),
                // )
                Padding(
                  padding: EdgeInsets.only(left: 80,top: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                        color: Color(0xFFFEDF00),
                    ),
                    height: 50,
                    width: 50,
                    child: IconButton(icon : Icon(Icons.camera_alt),
                    color: isDarkMode(context) ? Colors.white : Colors.black, onPressed: _onCameraClick),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 32, left: 32),
            child: Text(
              MyAppState.currentUser!.fullName(),
              style: TextStyle(fontFamily : "GlacialIndifference",color: isDarkMode(context) ? Colors.white : Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    push(context, AccountDetailsScreen());
                  },
                  title: Text(
                    'Account Details'.tr(),
                    style: const TextStyle(fontFamily : "GlacialIndifference",fontSize: 16),
                  ).tr(),
                  leading: const Icon(
                    CupertinoIcons.person_alt,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {
                    push(context, SettingsScreen(user: MyAppState.currentUser!));
                  },
                  title: Text(
                    'Settings'.tr(),
                    style: const TextStyle(fontFamily : "GlacialIndifference",fontSize: 16),
                  ).tr(),
                  leading: const Icon(
                    CupertinoIcons.settings,
                    color: Colors.grey,
                  ),
                ),
                ListTile(
                  onTap: () {
                    push(context, const ContactUsScreen());
                  },
                  title: Text(
                    'contactUs'.tr(),
                    style: const TextStyle(fontFamily : "GlacialIndifference",fontSize: 16),
                  ).tr(),
                  leading: const Hero(
                    tag: 'contactUs',
                    child: Icon(
                      CupertinoIcons.phone_solid,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () async {
                    AuthProviders? authProvider;
                    List<auth.UserInfo> userInfoList = auth.FirebaseAuth.instance.currentUser?.providerData ?? [];
                    await Future.forEach(userInfoList, (auth.UserInfo info) {
                      switch (info.providerId) {
                        case 'password':
                          authProvider = AuthProviders.PASSWORD;
                          break;
                        case 'phone':
                          authProvider = AuthProviders.PHONE;
                          break;
                        case 'facebook.com':
                          authProvider = AuthProviders.FACEBOOK;
                          break;
                        case 'apple.com':
                          authProvider = AuthProviders.APPLE;
                          break;
                      }
                    });
                    bool? result = await showDialog(
                      context: context,
                      builder: (context) => ReAuthUserScreen(
                        provider: authProvider!,
                        email: auth.FirebaseAuth.instance.currentUser!.email,
                        phoneNumber: auth.FirebaseAuth.instance.currentUser!.phoneNumber,
                        deleteUser: true,
                      ),
                    );
                    if (result != null && result) {
                      await showProgress(context, 'Deleting account...'.tr(), false);
                      await FireStoreUtils.deleteUser();
                      await hideProgress();
                      MyAppState.currentUser = null;
                      pushAndRemoveUntil(context, const AuthScreen(), false);
                    }
                  },
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(fontFamily : "GlacialIndifference",fontSize: 16),
                  ).tr(),
                  leading: const Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: isDarkMode(context) ? Colors.transparent : Color(0xFFFEDF00),
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: isDarkMode(context) ? Colors.grey.shade700 : Colors.grey.shade200)),
                ),
                child: Text(
                  'Log Out'.tr(),
                  style: TextStyle(fontFamily : "GlacialIndifference",fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode(context) ? Colors.white : Colors.black),
                ).tr(),
                onPressed: () async {
                  //MyAppState.currentUser!.active = false;
                  MyAppState.currentUser!.lastOnlineTimestamp = Timestamp.now();
                  await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
                  await auth.FirebaseAuth.instance.signOut();
                  MyAppState.currentUser = null;
                  pushAndRemoveUntil(context, const AuthScreen(), false);
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  _onCameraClick() {
    final action = CupertinoActionSheet(
      message: const Text(
        'Add Profile Picture',
        style: TextStyle(fontFamily : "GlacialIndifference",fontSize: 15.0),
      ).tr(),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: const Text('Remove picture').tr(),
          isDestructiveAction: true,
          onPressed: () async {
            Navigator.pop(context);
            showProgress(context, 'removingPicture'.tr(), false);
            MyAppState.currentUser!.profilePictureURL = '';
            await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
            hideProgress();
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('chooseImageFromGallery').tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Take a picture').tr(),
          onPressed: () async {
            Navigator.pop(context);
            XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
            if (image != null) {
              await _imagePicked(File(image.path));
            }
            setState(() {});
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel').tr(),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  Future<void> _imagePicked(File image) async {
    showProgress(context, 'Uploading image...'.tr(), false);
    MyAppState.currentUser!.profilePictureURL = await FireStoreUtils.uploadUserImageToFireStorage(image, MyAppState.currentUser!.userID);
    await FireStoreUtils.updateCurrentUser(MyAppState.currentUser!);
    hideProgress();
  }
}
