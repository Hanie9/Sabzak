import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/providers/cart_provider.dart';
import 'package:plant_app/screens/payment_options/payment_utils.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:provider/provider.dart';

class PaymentOptions extends StatefulWidget {
  const PaymentOptions({super.key});

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    intl.NumberFormat numberformat = intl.NumberFormat.decimalPattern('fa');

    return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const BuildCustomAppbar(appbarTitle: 'روش پرداخت'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.0,
    ),
    bottomNavigationBar: BottomAppBar(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        height: 80,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Constant.primaryColor.withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                SizedBox(
                  height: 20.0,
                  child: Image.asset('assets/images/7_7.png'),
                ),
                const SizedBox(width: 5.0),
                Text(
                  numberformat.format(cartProvider.getTotalAmount()),
                  style: TextStyle(
                    fontFamily: 'Lalezar',
                    color: Constant.primaryColor,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            const Text(
              textDirection: TextDirection.rtl,
              'مبلغ نهایی',
              style: TextStyle(
                fontFamily: 'Lalezar',
                fontSize: 25.0,
              ),
            ),
          ],
        ),
      ),
    ),
    body: _formUI(),
  );
}
  Widget _formUI(){
    return SingleChildScrollView(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              // ONLINE PAYMENTS

              const BuildPaymentOptions(
                icon: Icons.payment,
                paymentTitle: 'پرداخت آنلاین',
                paymentDescription: 'از روش‌های زیر یکی را انتخاب کنید',
              ),

              // PAYMENTS METHODS

              const SizedBox(height: 10.0),

              // ZARINPAL
              BuildClickPaymentMethod(
                assetImageUrl: 'assets/images/zarin.png',
                onPressed: () {},
                paymentTitle: 'زرین پال',
                paymentDescription: 'پرداخت آنلاین با درگــاه زرین پال',
              ),

              const SizedBox(height: 15.0),

              // NEXTPAY
              BuildClickPaymentMethod(
                assetImageUrl: 'assets/images/nexpay.png',
                onPressed: () {},
                paymentTitle: 'نکست پی',
                paymentDescription: 'پرداخت آنلاین با درگاه نکست پی',
              ),

              const SizedBox(height: 40.0),

              // OFFLINE PAYMENTS
              const BuildPaymentOptions(
                icon: Icons.payments,
                paymentTitle: 'پرداخت آفلاین',
                paymentDescription: 'از روش‌های زیر یکی را انتخاب کنید',
              ),

              const SizedBox(height: 10.0),

              // CASH ON DELEVERY
              BuildClickPaymentMethod(
                assetImageUrl: 'assets/images/cod.png',
                onPressed: () {
                  // Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  //   CupertinoPageRoute(
                  //     builder: (context) {
                  //       return const ProfilePage();
                  //     },
                  //   ),
                  //   (route) => false,
                  // );
                },
                paymentTitle: 'پرداخت در محل',
                paymentDescription: 'پرداخت درب منزل با دستگاه کارت خوان',
              ),
            ],
          )
        ) 
      )   
    );
  }
}