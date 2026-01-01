import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/providers/cart_provider.dart';
import 'package:plant_app/screens/root.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:provider/provider.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  late String _trackingCode;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _trackingCode = _generateTrackingCode();
    // Create order and clear cart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createOrderAndClearCart();
    });
  }

  Future<void> _createOrderAndClearCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cartProvider.cartItems;
    
    if (cartItems.isEmpty) {
      return;
    }

    try {
      // Prepare cart items for order
      final orderItems = cartItems.map((item) => {
        'plantid': item.plantId,
        'quantity': item.quantity,
        'price': item.price,
      }).toList();

      // Create order in backend
      await _apiService.createOrder(_trackingCode, orderItems);

      // Clear cart after order is created
      await cartProvider.clearCart();
    } catch (e) {
      print('Error creating order: $e');
      // Still clear cart even if order creation fails
      await cartProvider.clearCart();
    }
  }

  String _generateTrackingCode() {
    final random = Random();
    final code = random.nextInt(900000) + 100000; // 6 digit code
    return code.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'تکمیل خرید'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40.0),
                // Success Icon
                Container(
                  width: 120.0,
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80.0,
                  ),
                ),
                const SizedBox(height: 30.0),
                // Success Message
                const Text(
                  'خرید شما با موفقیت تکمیل شد!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Yekan Bakh',
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  'سفارش شما ثبت شد و در اسرع وقت برای شما ارسال خواهد شد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'iransans',
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40.0),
                // Tracking Code Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Constant.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: Constant.primaryColor.withOpacity(0.3),
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'کد پیگیری سفارش',
                        style: TextStyle(
                          fontFamily: 'iransans',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Text(
                        _trackingCode,
                        style: TextStyle(
                          fontFamily: 'Lalezar',
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Constant.primaryColor,
                          letterSpacing: 5.0,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'این کد را برای پیگیری سفارش خود نگه دارید',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'iransans',
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50.0),
                // Back to Shop Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constant.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        CupertinoPageRoute(
                          builder: (context) => const RootPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'بازگشت به فروشگاه',
                      style: TextStyle(
                        fontFamily: 'Yekan Bakh',
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

