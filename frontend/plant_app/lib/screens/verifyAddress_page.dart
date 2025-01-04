import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/payment_options/payment_options.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/build_custom_formfield.dart';
import 'package:plant_app/widgets/build_custom_formfield_star.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressVerificationPage extends StatefulWidget {

  const AddressVerificationPage({super.key});

  @override
  _AddressVerificationPageState createState() => _AddressVerificationPageState();
}

class _AddressVerificationPageState extends State<AddressVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _alleyController = TextEditingController();
  final _vahedController = TextEditingController();
  final _recieverFirstNameController = TextEditingController();
  final _recieverLastNameController = TextEditingController();
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://45.156.23.34:8000'));


@override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final address = await ApiService().fetchAddress();
      if (address != null) {
        _recieverFirstNameController.text = address['reciever_first_name'] ?? "";
        _recieverLastNameController.text = address['reciever_last_name'] ?? "";
        _streetController.text = address['street'] ?? '';
        _cityController.text = address['city'] ?? '';
        _houseNumberController.text = address['house_number'] ?? '';
        _zipCodeController.text = address['zip_code'] ?? '';
        _neighborhoodController.text = address ['neighborhood'] ?? "";
        _alleyController.text = address['alley'] ?? "";
        _vahedController.text = address['vahed'] ?? "";
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _verifyAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    if (_formKey.currentState!.validate()) {
      try {
        final response = await _dio.post(
          '/verify_address',
          options: Options(
            headers: {
              "session_id": sessionId
            }
          ),
          data: {
          'reciever_first_name': _recieverFirstNameController.text,
          'reciever_last_name': _recieverLastNameController.text,
          'street': _streetController.text,
          'city': _cityController.text,
          'neighborhood': _neighborhoodController.text,
          'zipCode': _zipCodeController.text,
          'houseNumber': _houseNumberController.text,
          'alley': _alleyController.text,
          'vahed': _vahedController.text,
        });
        if (_formKey.currentState!.validate()) {
          if (response.statusCode == 200) {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (BuildContext context) {
                  return const PaymentOptions();
                },
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مشکلی وجود دارد. آدرس شما ثبت نشد :(')),
        );
      }
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _alleyController.dispose();
    _houseNumberController.dispose();
    _zipCodeController.dispose();
    _recieverFirstNameController.dispose();
    _recieverLastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'تکمیل اطلاعات'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                margin: const EdgeInsets.only(top: 60.0),
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: BuildCustomFormFieldStar(
                            labelName: 'نام گیرنده:',
                            controller: _recieverFirstNameController,
                            validator: CustomValidator.fieldMustComplete,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Flexible(
                          child: BuildCustomFormFieldStar(
                            labelName: 'نام خانوادگی گیرنده:',
                            controller: _recieverLastNameController,
                            validator: CustomValidator.fieldMustComplete,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    BuildCustomFormFieldStar(
                      labelName: 'شهر:',
                      controller: _cityController,
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 15),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _neighborhoodController,
                        cursorColor: Constant.primaryColor,
                        style: const TextStyle(
                          fontFamily: 'YekanBakh',
                          fontSize: 20.0,
                          height: 2.0,
                        ),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(
                            fontFamily: 'YekanBakh',
                          ),
                          hintTextDirection: TextDirection.rtl,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Constant.primaryColor,
                              width: 1.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 15.0,
                          ),
                          label: Text(
                            "محله:",
                            style: TextStyle(
                              fontFamily: 'Lalezar',
                              fontSize: 20.0,
                              color: Constant.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    BuildCustomFormFieldStar(
                      controller: _streetController,
                      labelName: 'خیابان:',
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 15),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _alleyController,
                        cursorColor: Constant.primaryColor,
                        style: const TextStyle(
                          fontFamily: 'YekanBakh',
                          fontSize: 20.0,
                          height: 2.0,
                        ),
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(
                            fontFamily: 'YekanBakh',
                          ),
                          hintTextDirection: TextDirection.rtl,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Constant.primaryColor,
                              width: 1.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 15.0,
                          ),
                          label: Text(
                            "کوچه:",
                            style: TextStyle(
                              fontFamily: 'Lalezar',
                              fontSize: 20.0,
                              color: Constant.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Flexible(
                          child: BuildCustomFormFieldStar(
                            controller: _houseNumberController,
                            labelName: 'پلاک:',
                            validator: CustomValidator.fieldMustComplete,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: BuildCustomFormField(
                            controller: _vahedController,
                            labelName: 'واحد:',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    BuildCustomFormFieldStar(
                      controller: _zipCodeController,
                      labelName: 'کد پستی:',
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constant.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50.0,
                          vertical: 12.0,
                        ),
                      ),
                      onPressed: _verifyAddress,
                      child: const Text(
                        'مرحله بعدی',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Yekan Bakh',
                          fontSize: 20.0,
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
