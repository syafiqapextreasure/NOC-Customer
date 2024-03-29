import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocconsumer/model/referral_model.dart';
import 'package:nocconsumer/services/FirebaseHelper.dart';
import 'package:nocconsumer/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:nocconsumer/constants.dart';
import 'package:flutter_share/flutter_share.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  @override
  void initState() {
    // TODO: implement initState
    getReferralCode();
    super.initState();
  }

  ReferralModel? referralModel = ReferralModel();
  bool isLoading = true;

  getReferralCode() async {
    await FireStoreUtils.getReferralUserBy().then((value) {
      if (value != null) {
        setState(() {
          isLoading = false;
          referralModel = value;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFFFF662E),
          elevation: 0,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ))),
      body: isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : referralModel == null
              ?  Center(
                  child: Text("Something want wrong".tr()),
                )
              : Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/background_image_referral.png'),
                              fit: BoxFit.cover)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/earn_icon.png',
                              width: 160,
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                             Text(
                              "Refer your friends and".tr(),
                              style: const TextStyle(fontFamily : "GlacialIndifference",
                                  color: Colors.white, letterSpacing: 1.5),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Earn".tr() +
                                  " ${amountShow(amount: sectionConstantModel!.referralAmount.toString())} " +
                                  "each".tr(),
                              style: const TextStyle(fontFamily : "GlacialIndifference",
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // Text(
                            //   referralModel!.referralCode.toString(),
                            //   style: TextStyle(fontFamily : "GlacialIndifference",fontSize: 20, color: Colors.black),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Invite Friend & Businesses",
                          style: TextStyle(fontFamily : "GlacialIndifference",
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.0,
                              fontSize: 18),
                        ).tr(),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Invite Foodie to sign up using your code and you’ll get"
                                    .tr() +
                                " ${amountShow(amount: sectionConstantModel!.referralAmount.toString())}" +
                                "after successfully order complete.".tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily : "GlacialIndifference",
                                color: Color(0XFF666666),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2.0),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          onTap: () {
                            FlutterClipboard.copy(
                                    referralModel!.referralCode.toString())
                                .then((value) {
                              SnackBar snackBar = SnackBar(
                                content: Text(
                                  "Coupon code copied".tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontFamily : "GlacialIndifference",color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            });
                          },
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(2),
                            padding: const EdgeInsets.all(15),
                            color: const Color(COUPON_DASH_COLOR),
                            strokeWidth: 2,
                            dashPattern: const [5],
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Container(
                                  height: 25,
                                  width:
                                      MediaQuery.of(context).size.width * 0.30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: const Color(COUPON_BG_COLOR),
                                  ),
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    referralModel!.referralCode.toString(),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontFamily : "GlacialIndifference",
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                        color: Color(0xFFFEDF00)),
                                  )),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 40.0, left: 40.0, top: 60),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF662E),
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: const BorderSide(
                                    color: Color(0xFFFF662E),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                await showProgress(
                                    context, "Please wait".tr(), false);
                                share();
                              },
                              child: Text(
                                'Refer Friend'.tr(),
                                style: TextStyle(fontFamily : "GlacialIndifference",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode(context)
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
    );
  }

  Future<void> share() async {
    hideProgress();
    await FlutterShare.share(
      title: 'NOC',
      text: "Hey there, thanks for choosing NOC. Hope you love our product. If you do, share it with your friends using code"
              .tr() +
          " ${referralModel!.referralCode.toString()} " +
          "and get".tr() +
          "${amountShow(amount: sectionConstantModel!.referralAmount.toString())} " +
          "when order completed".tr(),
    );
  }
}
