import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/providers/cart_provider.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/extensions.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key,});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final ApiService apiService = ApiService();

    return Scaffold(
    appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'سبد خرید'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: cart.items.isEmpty ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100.0,
              child: Image.asset('assets/images/8_8.png'),
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              'سبد خرید تار عنکبوت بسته است :(',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'iransans',
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ) : Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (context, index) {
                final cartItem = cart.items.values.toList()[index];
                return ListTile(
                  leading: FutureBuilder<String>(
                    future: apiService.fetchPlantImage(cartItem.plant.plantId),
                    builder: (context, imageSnapshot) {
                      if (imageSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (imageSnapshot.hasError) {
                        return const Icon(Icons.error);
                      } else {
                        return Image.network(imageSnapshot.data!);
                      }
                    },
                  ),
                  title: Text(cartItem.plant.plantName),
                  subtitle: Text('Quantity: ${cartItem.quantity}'),
                );
              },
            ),
            ),
            Column(
              children: [
                const Divider(
                  thickness: 1.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 20.0,
                          child: Image.asset("assets/images/7_7.png"),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          cart.totalAmount.toStringAsFixed(2).farsiNumber,
                          style: TextStyle(
                            color: Constant.primaryColor,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'جمع کل',
                      style: TextStyle(
                        fontFamily: 'iransans',
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}