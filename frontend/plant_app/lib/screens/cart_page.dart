import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/providers/cart_provider.dart';
import 'package:plant_app/providers/loader_provider.dart';
import 'package:plant_app/screens/verifyAddress_page.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;

class CartPage extends StatefulWidget {
  const CartPage({super.key,});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCartItems();
    });
  }


  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final ApiService apiService = ApiService();
    intl.NumberFormat numberformat = intl.NumberFormat.decimalPattern('fa');

    return Scaffold(
    appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'سبد خرید'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.cartItems.isEmpty) {
            return Center(
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
            );
          } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 30.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        leading: FutureBuilder<String>(
                          future: apiService.fetchPlantImage(cartItem.plantId-1),
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
                        title: Text(cartItem.plantName),
                        trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              provider.increaseQuantity(cartItem.plantId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("مقدار ${cartItem.plantName} با موفقیت زیاد شد")),
                              );
                            },
                          ),
                          Text(
                            cartItem.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Lalezar",
                            ),
                          ),
                          cartItem.quantity > 1 
                          ? IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                provider.decreaseQuantity(cartItem.plantId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("مقدار ${cartItem.plantName} با موفقیت کم شد")),
                                );
                              }
                            ):
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              provider.deleteCartItem(cartItem.plantId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('گیاه ${cartItem.plantName} با موفقیت حذف شد')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
                              numberformat.format(cartProvider.getTotalAmount()),
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
                      Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            cartProvider.fetchCartItems();
                          },
                          icon: context.watch<LoaderProvider>().isApiCalled
                          ? SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: Constant.primaryColor,
                              size: 30.0
                            ),
                          )
                          : const Icon(Icons.sync),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                        ),
                        InkResponse(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                            decoration: BoxDecoration(
                              color: Constant.primaryColor,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0.0, 1.1),
                                  blurRadius: 5.0,
                                  color: Constant.primaryColor.withOpacity(0.3),
                                )
                              ],
                            ),
                            child: InkResponse(
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return const VerifyAddress();
                                    },
                                  )
                                );
                              },
                              child: const Text(
                                'مرحله بعد',
                                style: TextStyle(
                                  fontFamily: 'Lalezar',
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        }
      )
    );
  }
}