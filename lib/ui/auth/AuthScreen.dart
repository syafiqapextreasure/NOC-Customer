import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/constants.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/ui/StoreSelection/StoreSelection.dart';
import 'package:nocconsumer/ui/login/LoginScreen.dart';
import 'package:nocconsumer/ui/signUp/SignUpScreen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Align(
        //   alignment: Alignment.topRight,
        //   child: Padding(
        //     padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 40, bottom: 20),
        //     child: TextButton(
        //       child: Text(
        //         'Skip'.tr(),
        //         style: TextStyle(fontFamily : "GlacialIndifference",fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFEDF00)),
        //       ),
        //       onPressed: () {
        //         isSkipLogin = true;
        //         pushAndRemoveUntil(context, StoreSelection(), false);
        //       },
        //       style: ButtonStyle(
        //         padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        //           const EdgeInsets.only(top: 5, bottom: 5),
        //         ),
        //         shape: MaterialStateProperty.all<OutlinedBorder>(
        //           RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(25.0),
        //             side: BorderSide(
        //               color: Color(0xFFFEDF00),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/app_logo_new.png',
                fit: BoxFit.cover,
                width: 150,
                height: 150,
              ), 
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 32, right: 16, bottom: 8),
              child: Text(
                'Welcome to NOC'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily : "GlacialIndifference",
                    color: Colors.black,
                    fontSize: 24.0, fontWeight: FontWeight.bold),
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Text(
                "Order-store-around-track".tr(),
                style: const TextStyle(fontFamily : "GlacialIndifference",fontSize: 18),
                textAlign: TextAlign.center,
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFEDF00),
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                        color: Color(0xFFFEDF00),
                      ),
                    ),
                  ),
                  child: Text(
                    'Log In'.tr(),
                    style:  TextStyle(fontFamily : "GlacialIndifference",fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black ),
                  ).tr(),
                  onPressed: () {
                    push(context, LoginScreen());
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20, bottom: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: TextButton(
                  child: Text(
                    'signUp'.tr(),
                    style: TextStyle(fontFamily : "GlacialIndifference",fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black,),
                  ).tr(),
                  onPressed: () {
                    push(context, SignUpScreen());
                  },
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.only(top: 12, bottom: 12),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(
                          color: Color(0xFFFEDF00),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ]),
    );
  }
}
