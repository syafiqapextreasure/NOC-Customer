import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/AppGlobal.dart';
import 'package:nocconsumer/constants.dart';
import 'package:nocconsumer/ecommarce_service/view_all_category_product_screen.dart';
import 'package:nocconsumer/model/VendorCategoryModel.dart';
import 'package:nocconsumer/services/FirebaseHelper.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:nocconsumer/ui/categoryDetailsScreen/CategoryDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CuisinesScreen extends StatefulWidget {
  const CuisinesScreen({Key? key, this.isPageCallFromHomeScreen = false, this.isPageCallForDineIn = false}) : super(key: key);

  @override
  _CuisinesScreenState createState() => _CuisinesScreenState();
  final bool? isPageCallFromHomeScreen;
  final bool? isPageCallForDineIn;
}

class _CuisinesScreenState extends State<CuisinesScreen> {
  final fireStoreUtils = FireStoreUtils();
  late Future<List<VendorCategoryModel>> categoriesFuture;
  SharedPreferences? sp;
  String? lastID = "0";

  @override
  void initState() {
    super.initState();
    getLastId();
    categoriesFuture = fireStoreUtils.getCuisines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: isDarkMode(context) ? Colors.black : const Color(0xffFBFBFB),
        appBar: widget.isPageCallFromHomeScreen! ? AppGlobal.buildAppBar(context, "Categories".tr()) : null,
        body: FutureBuilder<List<VendorCategoryModel>>(
            future: categoriesFuture,
            initialData: const [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData || (snapshot.data?.isNotEmpty ?? false)) {
                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return snapshot.data != null ? buildCuisineCell(snapshot.data![index], lastID!) : showEmptyState('No Categories'.tr(), context);
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 0, crossAxisSpacing: 8, mainAxisExtent: 200),
                );
              }
              return const CircularProgressIndicator();
            }));
  }

  Widget buildCuisineCell(VendorCategoryModel cuisineModel, String lastID) {
    bool isSelected = (lastID == cuisineModel.id);
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            if (sp != null) {
              this.lastID = cuisineModel.id;
              sp!.setString("CatLastID", cuisineModel.id.toString());
              setState(() {});
            }
            if (sectionConstantModel!.serviceTypeFlag == "ecommerce-service") {
              push(
                context,
                ViewAllCategoryProductScreen(
                  vendorCategoryModel: cuisineModel,
                ),
              );
            } else {
              push(
                  context,
                  CategoryDetailsScreen(
                    category: cuisineModel,
                    isDineIn: widget.isPageCallForDineIn!,
                  ));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDarkMode(context) ? const Color(DarkContainerBorderColor) : Colors.grey.shade100, width: 1),
              color: isDarkMode(context) ? Color(DarkContainerColor) : Colors.white,
              boxShadow: [
                isDarkMode(context)
                    ? const BoxShadow()
                    : BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 5,
                      ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                      child: Image.network(
                    cuisineModel.photo.toString(),
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    cuisineModel.title.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily : "GlacialIndifference",fontSize: 18),
                  ).tr(),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> getLastId() async {
    sp = await SharedPreferences.getInstance();
    if (sp!.getString("CatLastID") != null) {
      lastID = sp?.getString("CatLastID");
    }
  }
}

//Container(
//             decoration: BoxDecoration(
//
//               borderRadius: BorderRadius.circular(8),
//               image: DecorationImage(
//                 image: NetworkImage(cuisineModel.photo),
//                 fit: BoxFit.cover,
//                 colorFilter: ColorFilter.mode(
//                     Colors.black.withOpacity(0.5), BlendMode.darken),
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 cuisineModel.title,
//                 style: TextStyle(fontFamily : "GlacialIndifference",
//                     color: Colors.white,  fontSize: 20),
//               ).tr(),
//             ),
//           ),
