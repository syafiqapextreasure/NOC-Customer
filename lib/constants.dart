import 'dart:io';
import 'dart:math';

import 'package:nocconsumer/model/CurrencyModel.dart';
import 'package:nocconsumer/model/SectionModel.dart';
import 'package:nocconsumer/model/VendorModel.dart';
import 'package:nocconsumer/model/mail_setting.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'model/TaxModel.dart';

const FINISHED_ON_BOARDING = 'finishedOnBoarding';
const COLOR_ACCENT = 0xFF8fd468;
var COLOR_PRIMARY = 0xFFFEDF00;
const FACEBOOK_BUTTON_COLOR = 0xFF415893;
const COUPON_BG_COLOR = 0xFFFCF8F3;
const DARK_BG_COLOR = 0xff121212;
const COUPON_DASH_COLOR = 0xFFCACFDA;
const GREY_TEXT_COLOR = 0xff5E5C5C;
const DarkContainerColor = 0xff26272C;
const DarkContainerBorderColor = 0xff515151;
const DARK_VIEWBG_COLOR = 0xff191A1C;

String appVersion = '';

const USERS = 'users';
const VEHICLETYPE = 'vehicle_type';
const RENTALVEHICLETYPE = 'rental_vehicle_type';
const REPORTS = 'reports';
const Deliverycharge = 6;
const CATEGORIES = 'vendor_categories';
const VENDORS = 'vendors';
const PRODUCTS = 'vendor_products';
const SECTION = 'sections';
const SERVICE = 'service';
const BANNER = 'Banner';
const PAYID = 'eMart';
String Banner_Url = '';
const ORDERS = 'vendor_orders';
const VENDOR_ATTRIBUTES = "vendor_attributes";
const BRANDS = "brands";
const REVIEW_ATTRIBUTES = "review_attributes";
const SOS = 'SOS';
const complaints = 'complaints';
const COUPONS = "coupons";
const CAB_COUPONS = "promos";
const PARCELCOUPONS = "parcel_coupons";
const RENTALCOUPONS = "rental_coupons";
const ORDERS_TABLE = 'booked_table';
const POPULAR_DESTINATION = 'popular_destinations';
const dynamicNotification = 'dynamic_notification';
const STORY = 'story';
const REFERRAL = 'referral';
const emailTemplates = 'email_templates';

//String SELECTED_CATEGORY = "";
//String SELECTED_SECTION_NAME = "";
//String serviceTypeFlag = "";
//String ecommarceDileveryCharges = "";
//String referralAmount = "";

//bool isDineEnable = false;
bool isSkipLogin = false;
const SECOND_MILLIS = 1000;
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;
String SERVER_KEY = 'AAAAYKYVaUA:APA91bGOSiK4mbR5tYbpYlHuS0iElkV5UE3T1QaUzJQbzzX39h87rD9blQIjl9ER0ksBScmIomRO96YtS4ZVjjYDbH3jcFb_a00WzA3OWnKVKiSsuSle24bWHuSZCsQZQjKNDXRZ3WdS';
String GOOGLE_API_KEY = 'AIzaSyAvNwZ_RUaMuDHblwRJBi1QYs8oZQK8xOs';

const ORDER_STATUS_PLACED = 'Order Placed';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_ACCEPTED = 'Driver Accepted';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';
const ORDER_STATUS_COMPLETED = 'Order Completed';
const ORDER_REACHED_DESTINATION = 'Reached Destination';


const dineInPlaced = "dinein_placed";
const orderPlaced = "order_placed";
const scheduleOrder = "schedule_order";
const rentalBooked = "rental_booked";

const walletTopup = "wallet_topup";
const newVendorSignup = "new_vendor_signup";
const payoutRequestStatus = "payout_request_status";
const payoutRequest = "payout_request";
const newOrderPlaced = "new_order_placed";
const newRideBook = "new_ride_book";
const newParcelBook = "new_parcel_book";
const newCarBook = "new_car_book";

const MENU_ITEM = 'banner_items';

const ORDERREQUEST = 'Order';
const BOOKREQUEST = 'TableBook';

const STRIPE_CURRENCY_CODE = 'USD';

const USER_ROLE_DRIVER = 'driver';
const USER_ROLE_CUSTOMER = 'customer';
const USER_ROLE_VENDOR = 'vendor';

const Order_Rating = 'items_review';
const CONTACT_US = 'ContactUs';
const COUPON = 'coupons';
const Wallet = "wallet";
const RIDESORDER = "rides";
const PARCELORDER = "parcel_orders";
const RENTALORDER = "rental_orders";

const PARCELCATEGORY = "parcel_categories";
const PARCELWEIGHT = "parcel_weight";

const Setting = 'settings';
const StripeSetting = 'stripeSettings';
const FavouriteStore = "favorite_vendor";
const FavouriteItem = "favorite_item";
const COD = 'CODSettings';
const TermsAndConditions = 'terms_and_condition';

const GlobalURL = "https://nocglobal.my/";

const Currency = 'currencies';
double radiusValue = 0.0;


const STORAGE_ROOT = 'noc';
bool isLanguageShown = false;
CurrencyModel? currencyData;
SectionModel? sectionConstantModel;
List<VendorModel> allstoreList = [];

bool isRazorPayEnabled = false;
bool isRazorPaySandboxEnabled = false;
String razorpayKey = "";
String razorpaySecret = "";


String placeholderImage = 'https://firebasestorage.googleapis.com/v0/b/emart-8d99f.appspot.com/o/images%2Flogo_placeholder.png?alt=media&token=9593b0c4-6f11-4979-917f-08fa895318c1';
const tax = 'tax';
List<TaxModel>? taxList = [];
String? country = "";

String getReferralCode() {
  var rng = Random();
  return (rng.nextInt(900000) + 100000).toString();
}

double getDoubleVal(dynamic input) {
  if (input == null) {
    return 0.1;
  }

  if (input is int) {
    return double.parse(input.toString());
  }

  if (input is double) {
    return input;
  }
  return 0.1;
}

String getFileName(String url) {
  RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
  //This Regex won't work if you remove ?alt...token
  var matches = regExp.allMatches(url);

  var match = matches.elementAt(0);
  print(Uri.decodeFull(match.group(2)!));
  return Uri.decodeFull(match.group(2)!);
}

// double getTaxValue(TaxModel? taxModel, double amount) {
//  double taxVal = 0;
//   if (taxModel != null && taxModel.tax_amount != null && taxModel.tax_amount! > 0) {
//     if (taxModel.tax_type == "fix") {
//       taxVal = taxModel.tax_amount!.toDouble();
//     } else {
//       taxVal = (amount * taxModel.tax_amount!.toDouble()) / 100;
//     }
//   }
//   return double.parse(taxVal.toStringAsFixed(currencyData!.decimal));
// }


double getTaxValue({String? amount, TaxModel? taxModel}) {
  double taxVal = 0.0;
  if (taxModel != null && taxModel.enable == true) {
    if (taxModel.type == "fix") {
      taxVal = double.parse(taxModel.tax.toString());
    } else {
      taxVal = (double.parse(amount.toString()) * double.parse(taxModel.tax!.toString())) / 100;
    }
  }
  return taxVal;
}


Uri createCoordinatesUrl(double latitude, double longitude, [String? label]) {
  var uri;
  if (kIsWeb) {
    uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$latitude,$longitude'});
  } else if (Platform.isAndroid) {
    var query = '$latitude,$longitude';
    if (label != null) query += '($label)';
    uri = Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': query});
  } else if (Platform.isIOS) {
    var params = {'ll': '$latitude,$longitude'};
    if (label != null) params['q'] = label;
    uri = Uri.https('maps.apple.com', '/', params);
  } else {
    uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$latitude,$longitude'});
  }

  return uri;
}
String amountShow({required String? amount}) {
  if (currencyData!.symbolatright == true) {
    return "${double.parse(amount.toString()).toStringAsFixed(currencyData!.decimal)} ${currencyData!.symbol.toString()}";
  } else {
    return "${currencyData!.symbol.toString()} ${double.parse(amount.toString()).toStringAsFixed(currencyData!.decimal)}";
  }
}

String getKm(Position pos1, Position pos2) {
  double distanceInMeters = Geolocator.distanceBetween(pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
  double kilometer = distanceInMeters / 1000;
  return kilometer.toStringAsFixed(currencyData!.decimal).toString();
}

String getImageVAlidUrl(String url) {
  String imageUrl = placeholderImage;
  if (url != null && url.isNotEmpty) {
    imageUrl = url;
  }
  return imageUrl;
}

MailSettings? mailSettings;

final smtpServer = SmtpServer(mailSettings!.host.toString(), username: mailSettings!.userName.toString(), password: mailSettings!.password.toString(), port: 465, ignoreBadCertificate: false, ssl: true, allowInsecure: true);

sendMail({String? subject, String? body, bool? isAdmin = false, List<dynamic>? recipients}) async {
  // Create our message.
  if (isAdmin == true) {
    recipients!.add(mailSettings!.userName.toString());
  }
  final message = Message()
    ..from = Address(
        mailSettings!.userName.toString(), mailSettings!.fromName.toString())
    ..recipients = recipients!
    ..subject = subject
    ..text = body
    ..html = body;

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: ' + sendReport.toString());
  } on MailerException catch (e) {
    print(e);
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}
