import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/AppGlobal.dart';
import 'package:nocconsumer/constants.dart';
import 'package:nocconsumer/main.dart';
import 'package:nocconsumer/model/AddressModel.dart';
import 'package:nocconsumer/model/FavouriteModel.dart';
import 'package:nocconsumer/model/ProductModel.dart';
import 'package:nocconsumer/model/User.dart';
import 'package:nocconsumer/model/VendorCategoryModel.dart';
import 'package:nocconsumer/model/VendorModel.dart';
import 'package:nocconsumer/services/FirebaseHelper.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/ui/categoryDetailsScreen/CategoryDetailsScreen.dart';
import 'package:nocconsumer/ui/cuisinesScreen/CuisinesScreen.dart';
import 'package:nocconsumer/ui/dineInScreen/dine_in_restaurant_details_screen.dart';
import 'package:nocconsumer/ui/home/CurrentAddressChangeScreen.dart';
import 'package:nocconsumer/ui/home/view_all_new_arrival_store_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';

class DineInScreen extends StatefulWidget {
  final User? user;

  const DineInScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DineInScreen> createState() => _DineInScreenState();
}

class _DineInScreenState extends State<DineInScreen> {
  loc.Location location = loc.Location();
  String? currentLocation = "", name = "";
  final fireStoreUtils = FireStoreUtils();

  Stream<List<VendorModel>>? lstVendor;
  Stream<List<VendorModel>>? lstAllRestaurant;
  Stream<List<VendorModel>>? lstNewArrivalRestaurant;
  Stream<List<VendorModel>>? lstPopularRestaurant;
  late Future<List<FavouriteModel>> lstFavourites;
  late Future<List<VendorCategoryModel>> cuisinesFuture;
  List<String> lstFav = [];
  List<VendorModel> newArrivalLst = [];
  List<VendorModel> restaurantAllLst = [];
  List<VendorModel> popularRestaurantLst = [];
  List<VendorModel> lstNearByFood = [];
  bool showLoader = true;
  late Future<List<ProductModel>> productsFuture;
  List<VendorModel> vendors = [];
  VendorModel? popularNearFoodVendorModel;

  _getLocation() async {
    if (MyAppState.selectedPosition.longitude == 0 &&
        MyAppState.selectedPosition.latitude == 0) {
      Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .whenComplete(() {});
      MyAppState.selectedPosition = position;
    }

    debugPrint('location: ${MyAppState.selectedPosition.latitude}');

    List<Placemark> placemarks = await placemarkFromCoordinates(
        MyAppState.selectedPosition.latitude,
        MyAppState.selectedPosition.longitude);
    Placemark placeMark = placemarks[0];
    setState(() {
      currentLocation = placeMark.name.toString() +
          ", " +
          placeMark.subLocality.toString() +
          ", " +
          placeMark.locality.toString() +
          ", " +
          placeMark.administrativeArea.toString() +
          ", " +
          placeMark.postalCode.toString() +
          ", " +
          placeMark.country.toString();
    });
    if (MyAppState.currentUser != null) {
      AddressModel userAddress = AddressModel(
          name: MyAppState.currentUser!.fullName(),
          postalCode: placeMark.postalCode.toString(),
          line1: placeMark.name.toString() +
              ", " +
              placeMark.subLocality.toString(),
          line2: placeMark.administrativeArea.toString(),
          country: placeMark.country.toString(),
          city: placeMark.locality.toString(),
          location: MyAppState.currentUser!.location,
          email: MyAppState.currentUser!.email);
      MyAppState.currentUser!.shippingAddress = userAddress;
      await FireStoreUtils.updateCurrentUserAddress(userAddress);
    }
  }

  bool isLocationPermissionAllowed = false;

  getLoc() async {
    bool _serviceEnabled;

    _serviceEnabled = await location.requestService();
    if (_serviceEnabled) {
      var status = await Permission.location.status;
      if (status.isDenied) {
        if (Platform.isIOS) {
          status = await Permission.locationWhenInUse.request();
        } else {
          status = await Permission.location.request();
        }

        if (status.isGranted) {
          _getLocation();
          getData();
        } else if (status.isPermanentlyDenied) {
          if (Platform.isIOS) {
            openAppSettings();
          } else {
            await Permission.contacts.shouldShowRequestRationale;
            if (status.isPermanentlyDenied) {
              getTempLocation();
            }
          }
        }
      } else if (status.isRestricted) {
        getTempLocation();
      } else if (status.isPermanentlyDenied) {
        if (Platform.isIOS) {
          openAppSettings();
        } else {
          await Permission.contacts.shouldShowRequestRationale;
        }
      } else {
        _getLocation();
        getData();
      }
      return;
    } else {
      getTempLocation();
    }
    //_currentPosition = await location.getLocation();
  }

  @override
  void initState() {
    super.initState();
    getLoc();
    cuisinesFuture = fireStoreUtils.getCuisines();
  }

  void dispose() {
    super.dispose();
  }

  void getData() {
    fireStoreUtils.getStoreNearBy().whenComplete(() {
      lstVendor =
          fireStoreUtils.getVendors1(path: "isDineIn").asBroadcastStream();
      lstAllRestaurant =
          fireStoreUtils.getAllDineInRestaurants().asBroadcastStream();
      lstNewArrivalRestaurant = fireStoreUtils
          .getVendorsForNewArrival(path: "isDineIn")
          .asBroadcastStream();
      lstPopularRestaurant = fireStoreUtils
          .getPopularsVendors(path: "isDineIn")
          .asBroadcastStream();
      if (MyAppState.currentUser != null) {
        lstFavourites =
            fireStoreUtils.getFavouriteStore(MyAppState.currentUser!.userID);
        lstFavourites.then((event) {
          lstFav.clear();
          for (int a = 0; a < event.length; a++) {
            lstFav.add(event[a].store_id!);
          }
        });
        name = toBeginningOfSentenceCase(widget.user!.firstName);
      }
      lstVendor!.listen((event) {
        setState(() {
          vendors.addAll(event);
        });
        restaurantAllLst.clear();
        restaurantAllLst.addAll(event);
        for (int a = 0; a < restaurantAllLst.length; a++) {
          if ((restaurantAllLst[a].reviewsSum /
                  restaurantAllLst[a].reviewsCount) >=
              4.0) {
            popularRestaurantLst.add(restaurantAllLst[a]);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLocationAvail = (MyAppState.selectedPosition.latitude == 0 &&
        MyAppState.selectedPosition.longitude == 0);
    return Scaffold(
      backgroundColor:
          isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
      body: isLocationAvail
          ? showEmptyState("We don't have your\nlocation.".tr(), context,
              action: () async {
              LocationResult result = await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => PlacePicker(GOOGLE_API_KEY)));

              setState(() {
                MyAppState.selectedPosition = Position.fromMap({
                  'latitude': result.latLng!.latitude,
                  'longitude': result.latLng!.longitude,
                  'timestamp': DateTime.now().microsecondsSinceEpoch
                });

                currentLocation = result.formattedAddress;
                getData();
              });
            }, buttonTitle: 'Select'.tr())
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFFFEDF00),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Text(currentLocation.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily : "GlacialIndifference",color: Color(0xFFFEDF00)))
                              .tr(),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const CurrentAddressChangeScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return child;
                              },
                            ))
                                .then((value) {
                              if (value != null) {
                                setState(() {
                                  currentLocation = value;
                                  getData();
                                });
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.black12,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: Text("Change".tr(),
                                    style: TextStyle(fontFamily : "GlacialIndifference",
                                        fontSize: 14,
                                        color: Color(0xFFFEDF00)))
                                .tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 10),
                    child: Text("Find your store".tr(),
                            style: TextStyle(fontFamily : "GlacialIndifference",
                                fontSize: 24,
                                color: isDarkMode(context)
                                    ? Colors.white
                                    : const Color(0xFF333333)))
                        .tr(),
                  ),
                  buildDineInTitleRow(
                    titleValue: "Categories".tr(),
                    onClick: () {
                      push(
                        context,
                        const CuisinesScreen(
                          isPageCallFromHomeScreen: true,
                          isPageCallForDineIn: true,
                        ),
                      );
                    },
                  ),
                  Container(
                    color: isDarkMode(context)
                        ? Colors.black
                        : const Color(0xffFFFFFF),
                    child: FutureBuilder<List<VendorCategoryModel>>(
                        future: cuisinesFuture,
                        initialData: const [],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(
                                    Color(0xFFFEDF00)),
                              ),
                            );
                          }

                          if (snapshot.hasData ||
                              (snapshot.data?.isNotEmpty ?? false)) {
                            return SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length >= 15
                                      ? 15
                                      : snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return buildCategoryItem(
                                        snapshot.data![index]);
                                  },
                                ));
                          } else {
                            return showEmptyState(
                                'No Categories'.tr(), context);
                          }
                        }),
                  ),
                  buildDineInTitleRow(
                    titleValue: "New Arrivals".tr(),
                    onClick: () {
                      push(
                          context,
                          const ViewAllNewArrivalStoreScreen(
                            isPageCallForDineIn: true,
                          ));
                    },
                  ),
                  StreamBuilder<List<VendorModel>>(
                      stream: lstNewArrivalRestaurant,
                      initialData: const [],
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation(Color(0xFFFEDF00)),
                            ),
                          );
                        }

                        if (snapshot.hasData ||
                            (snapshot.data?.isNotEmpty ?? false)) {
                          newArrivalLst = snapshot.data!;

                          return Container(
                              height: MediaQuery.of(context).size.height * 0.32,
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: newArrivalLst.length >= 15
                                      ? 15
                                      : newArrivalLst.length,
                                  itemBuilder: (context, index) =>
                                      buildNewArrivalItem(
                                          newArrivalLst[index])));
                        } else {
                          return showEmptyState('No Vendors'.tr(), context);
                        }
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: buildDineInTitleRow(
                      titleValue: "Popular Restaurants".tr(),
                      onClick: () {
                        push(
                            context,
                            const ViewAllNewArrivalStoreScreen(
                              isPageCallForDineIn: true,
                              isPageCallForPopular: true,
                            ));
                      },
                    ),
                  ),
                  StreamBuilder<List<VendorModel>>(
                      stream: lstPopularRestaurant,
                      initialData: const [],
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator.adaptive(
                              valueColor:
                                  AlwaysStoppedAnimation(Color(0xFFFEDF00)),
                            ),
                          );
                        }

                        if (snapshot.hasData ||
                            (snapshot.data?.isNotEmpty ?? false)) {
                          lstNearByFood = snapshot.data!;

                          return Container(
                              height: MediaQuery.of(context).size.height * 0.32,
                              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: lstNearByFood.length >= 15
                                      ? 15
                                      : lstNearByFood.length,
                                  itemBuilder: (context, index) =>
                                      buildNewArrivalItem(
                                          lstNearByFood[index])));
                        } else {
                          return showEmptyState('No Vendors'.tr(), context);
                        }
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: buildDineInTitleRow(
                      titleValue: "All Restaurants around you".tr(),
                      onClick: () {},
                      isViewAll: true,
                    ),
                  ),
                  Builder(builder: (context) {
                    return StreamBuilder<List<VendorModel>>(
                        stream: lstAllRestaurant,
                        initialData: const [],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator.adaptive(
                                valueColor: AlwaysStoppedAnimation(
                                    Color(0xFFFEDF00)),
                              ),
                            );
                          }

                          if (snapshot.hasData ||
                              (snapshot.data?.isNotEmpty ?? false)) {
                            vendors.clear();
                            vendors.addAll(snapshot.data!);
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: vendors.length,
                                  itemBuilder: (context, index) =>
                                      buildAllRestaurantsData(vendors[index])),
                            );
                          } else {
                            return showEmptyState('No Vendors'.tr(), context);
                          }
                        });
                  }),
                ],
              ),
            ),
    );
  }

  Future<void> getTempLocation() async {
    debugPrint('location: ${MyAppState.selectedPosition}');
    if (MyAppState.currentUser == null &&
        MyAppState.selectedPosition.longitude != 0 &&
        MyAppState.selectedPosition.latitude != 0) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          MyAppState.selectedPosition.latitude,
          MyAppState.selectedPosition.longitude);
      Placemark placeMark = placemarks[0];
      setState(() {
        currentLocation = placeMark.name.toString() +
            ", " +
            placeMark.subLocality.toString() +
            ", " +
            placeMark.locality.toString() +
            ", " +
            placeMark.administrativeArea.toString() +
            ", " +
            placeMark.postalCode.toString() +
            ", " +
            placeMark.country.toString();
      });
      getData();
    }
    if (MyAppState.currentUser != null) {
      if (MyAppState.currentUser!.location.longitude != null &&
          MyAppState.currentUser!.location.latitude != 0 &&
          MyAppState.currentUser!.location.longitude != 0) {
        MyAppState.selectedPosition = Position.fromMap({
          'latitude': MyAppState.currentUser!.location.latitude,
          'longitude': MyAppState.currentUser!.location.longitude,
          'timestamp': DateTime.now().microsecondsSinceEpoch
        });
        List<Placemark> placemarks = await placemarkFromCoordinates(
            MyAppState.selectedPosition.latitude,
            MyAppState.selectedPosition.longitude);
        Placemark placeMark = placemarks[0];
        setState(() {
          currentLocation = placeMark.name.toString() +
              ", " +
              placeMark.subLocality.toString() +
              ", " +
              placeMark.locality.toString() +
              ", " +
              placeMark.administrativeArea.toString() +
              ", " +
              placeMark.postalCode.toString() +
              ", " +
              placeMark.country.toString();
        });
        getData();
      }
      setState(() {});
    }
  }

  buildCategoryItem(VendorCategoryModel cuisineModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          push(
              context,
              CategoryDetailsScreen(
                category: cuisineModel,
                isDineIn: true,
              ));
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.23,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: getImageVAlidUrl(cuisineModel.photo.toString()),
                imageBuilder: (context, imageProvider) => Container(
                  height: MediaQuery.of(context).size.height * 0.11,
                  width: MediaQuery.of(context).size.width * 0.22,
                  decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Color(0xFFFEDF00)),
                      borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: isDarkMode(context)
                              ? Colors.black
                              : const Color(0xffE0E2EA),
                        ),
                        borderRadius: BorderRadius.circular(30)),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      AppGlobal.placeHolderImage!,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    )),
                placeholder: (context, url) => ClipOval(
                  child: Container(
                    // padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(75 / 1)),
                      border: Border.all(
                        color: Color(0xFFFEDF00),
                        style: BorderStyle.solid,
                        width: 2.0,
                      ),
                    ),
                    width: 75,
                    height: 75,
                    child: Icon(
                      Icons.fastfood,
                      color: Color(0xFFFEDF00),
                    ),
                  ),
                ),
              ),
              // displayCircleImage(model.photo, 90, false),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(cuisineModel.title.toString(),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily : "GlacialIndifference",
                      color: isDarkMode(context)
                          ? Colors.white
                          : const Color(0xFF000000),
                    )).tr(),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildNewArrivalItem(VendorModel vendorModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: GestureDetector(
        onTap: () {
          push(
            context,
            DineInRestaurantDetailsScreen(vendorModel: vendorModel),
          );
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100, width: 0.1),
                boxShadow: [
                  isDarkMode(context)
                      ? const BoxShadow()
                      : BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 8.0,
                          spreadRadius: 1.2,
                          offset: const Offset(0.2, 0.2),
                        ),
                ],
                color: Colors.white),
            child: Column(
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: getImageVAlidUrl(vendorModel.photo),
                  width: MediaQuery.of(context).size.width * 0.75,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFEDF00)),
                  )),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        placeholderImage,
                        width: MediaQuery.of(context).size.width * 0.75,
                        fit: BoxFit.fitWidth,
                      )),
                  fit: BoxFit.cover,
                )),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 5, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendorModel.title,
                          maxLines: 1,
                          style: const TextStyle(fontFamily : "GlacialIndifference",
                            letterSpacing: 0.5,
                            color: Color(0xff000000),
                          )).tr(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const ImageIcon(
                            AssetImage('assets/images/location3x.png'),
                            size: 15,
                            color: Color(0xff9091A4),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(vendorModel.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily : "GlacialIndifference",
                                  letterSpacing: 0.5,
                                  color: Color(0xff555353),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xff555353),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                      getKm(vendorModel.latitude,
                                              vendorModel.longitude)! +
                                          " km".tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontFamily : "GlacialIndifference",
                                        color: Color(0xff555353),
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Color(0xFFFEDF00),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                    vendorModel.reviewsCount != 0
                                        ? (vendorModel.reviewsSum /
                                                vendorModel.reviewsCount)
                                            .toStringAsFixed(1)
                                        : 0.toString(),
                                    style: const TextStyle(fontFamily : "GlacialIndifference",
                                      letterSpacing: 0.5,
                                      color: Color(0xff000000),
                                    )),
                                const SizedBox(width: 3),
                                Text(
                                    '(${vendorModel.reviewsCount.toStringAsFixed(1)})',
                                    style: const TextStyle(fontFamily : "GlacialIndifference",
                                      letterSpacing: 0.5,
                                      color: Color(0xff666666),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? getKm(double latitude, double longitude) {
    double distanceInMeters = Geolocator.distanceBetween(
        latitude,
        longitude,
        MyAppState.selectedPosition.latitude,
        MyAppState.selectedPosition.longitude);
    double kilometer = distanceInMeters / 1000;

    double minutes = 1.2;
    return kilometer.toStringAsFixed(currencyData!.decimal).toString();
  }

  buildAllRestaurantsData(VendorModel vendor) {
    return GestureDetector(
      onTap: () {
        push(
          context,
          DineInRestaurantDetailsScreen(vendorModel: vendor),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: getImageVAlidUrl(vendor.photo),
                height: 100,
                width: 100,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Center(
                    child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Color(0xFFFEDF00)),
                )),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      vendor.photo,
                      fit: BoxFit.cover,
                    )),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.title,
                          style: const TextStyle(fontFamily : "GlacialIndifference",
                            fontSize: 16,
                            color: Color(0xff000000),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (lstFav.contains(vendor.id) == true) {
                              FavouriteModel favouriteModel = FavouriteModel(
                                  store_id: vendor.id,
                                  user_id: MyAppState.currentUser!.userID,
                                  section_id: sectionConstantModel!.id);
                              lstFav.removeWhere((item) => item == vendor.id);
                              fireStoreUtils
                                  .removeFavouriteStore(favouriteModel);
                            } else {
                              FavouriteModel favouriteModel = FavouriteModel(
                                  store_id: vendor.id,
                                  user_id: MyAppState.currentUser!.userID);
                              fireStoreUtils.setFavouriteStore(favouriteModel);
                              lstFav.add(vendor.id);
                            }
                          });
                        },
                        child: lstFav.contains(vendor.id) == true
                            ? Icon(
                                Icons.favorite,
                                color: Color(0xFFFEDF00),
                              )
                            : const Icon(
                                Icons.favorite_border,
                                color: Colors.black38,
                              ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.location,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontFamily : "GlacialIndifference",
                            color: Color(0xff9091A4),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          children: [
                            Container(
                              height: 5,
                              width: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xff555353),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                  getKm(vendor.latitude, vendor.longitude)! +
                                      " km".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily : "GlacialIndifference",
                                    color: Color(0xff555353),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 20,
                        color: Color(0xFFFEDF00),
                      ),
                      const SizedBox(width: 3),
                      Text(
                          vendor.reviewsCount != 0
                              ? (vendor.reviewsSum / vendor.reviewsCount)
                                  .toStringAsFixed(1)
                              : 0.toString(),
                          style: const TextStyle(fontFamily : "GlacialIndifference",
                            letterSpacing: 0.5,
                            color: Color(0xff000000),
                          )),
                      const SizedBox(width: 3),
                      Text('(${vendor.reviewsCount.toStringAsFixed(1)})',
                          style: const TextStyle(fontFamily : "GlacialIndifference",
                            letterSpacing: 0.5,
                            color: Color(0xff666666),
                          )),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class buildDineInTitleRow extends StatelessWidget {
  final String titleValue;
  final Function? onClick;
  final bool? isViewAll;

  const buildDineInTitleRow({
    Key? key,
    required this.titleValue,
    this.onClick,
    this.isViewAll = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        color: isDarkMode(context) ? Colors.black : const Color(0xffFFFFFF),
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleValue.tr(),
                  style: TextStyle(fontFamily : "GlacialIndifference",
                      color: isDarkMode(context)
                          ? Colors.white
                          : const Color(0xFF000000),
                      fontSize: 16)),
              isViewAll!
                  ? Container()
                  : GestureDetector(
                      onTap: () {
                        onClick!.call();
                      },
                      child: Text('View All'.tr(),
                          style: TextStyle(fontFamily : "GlacialIndifference",color: Color(0xFFFEDF00))),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
