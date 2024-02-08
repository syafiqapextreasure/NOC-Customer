import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/constants.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/ui/dineInScreen/HistoryTableBooking.dart';
import 'package:nocconsumer/ui/dineInScreen/UpComingTableBooking.dart';
import 'package:flutter/material.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  List<Widget> list = [
    Tab(text: "Upcoming".tr()),
    Tab(text: "History".tr()),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
          appBar: TabBar(
            labelColor: Color(0xFFFEDF00),
            indicatorColor: Color(0xFFFEDF00),
            unselectedLabelColor: const Color(GREY_TEXT_COLOR),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: list,
          ),
          body: const TabBarView(children: [
            UpComingTableBooking(),
            HistoryTableBooking(),
          ])),
    );
  }
}
