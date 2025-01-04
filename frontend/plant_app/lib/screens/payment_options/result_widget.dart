import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/providers/cart_provider.dart';
import 'package:plant_app/providers/loader_provider.dart';

class PaymentResult extends StatelessWidget {
  final String image;
  final String paymentResultText;
  final String paymentRefID;
  final CartProvider shopProvider;
  final LoaderProvider loaderProvider;
  const PaymentResult({
    super.key,
    required this.image,
    required this.paymentResultText,
    required this.paymentRefID,
    required this.shopProvider,
    required this.loaderProvider
  });

  @override
  Widget build(BuildContext context) {
    intl.NumberFormat numberFormat = intl.NumberFormat.decimalPattern('fa');
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100.0),
          Image.asset(
            image,
            width: 300.0,
            height: 300.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Text(
              paymentResultText,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Lalezar',
                fontSize: 30.0
              ),
            ),
          ),
          const SizedBox(height: 25.0,),
          Text(
            numberFormat.format("کد پیگیری تراکنش : $paymentRefID"),
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Yekan Bakh',
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 50.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constant.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 12.0,
                  )
                ),
                onPressed: () {
                  shopProvider.clearCart();
                },
                child: const Text(
                  "بازگشت به صفحه اصلی",
                  style: TextStyle(
                    fontFamily: "Yekan Bakh",
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}