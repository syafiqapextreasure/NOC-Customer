import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/ui/mapView/MapViewScreen.dart';
import 'package:nocconsumer/ui/searchScreen/SearchScreen.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class AppGlobal {
  static double deliveryCharges = 0.0;

  static String? placeHolderImage = "";

  static AppBar buildAppBar(BuildContext context, String title) {
    return AppBar(
      centerTitle: false,
      backgroundColor: isDarkMode(context) ? Colors.black : null,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Color(0xFFFEDF00),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontFamily : "GlacialIndifference",color: isDarkMode(context) ? Colors.white : Colors.black, fontWeight: FontWeight.normal),
      ),
      actions: [
        IconButton(
            padding: const EdgeInsets.only(right: 7),
            icon: Image(
              image: const AssetImage("assets/images/search.png"),
              width: 20,
              color: isDarkMode(context) ? Colors.white : null,
            ),
            onPressed: () async {
              push(
                context,
                const SearchScreen(),
              );
            }),
        IconButton(
          padding: const EdgeInsets.only(right: 7),
          icon: Image(
            image: const AssetImage("assets/images/map.png"),
            width: 20,
            color: isDarkMode(context) ? Colors.white : const Color(0xFF333333),
          ),
          onPressed: () => push(
            context,
            const MapViewScreen(),
          ),
        ),
      ],
    );
  }

  static AppBar buildSimpleAppBar(BuildContext context, String title) {
    return AppBar(
      centerTitle: false,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: isDarkMode(context) ? Color(0xFFFEDF00) : Colors.black,
        ),
      ),
      title: Text(title, style: TextStyle(fontFamily : "GlacialIndifference",color: isDarkMode(context) ? Colors.white : Colors.black)).tr(),
    );
  }
}
