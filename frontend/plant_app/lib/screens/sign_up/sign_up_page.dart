import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/sign_up.dart';
import 'package:plant_app/providers/login_provider.dart';
import 'package:plant_app/providers/signup_provider.dart';
import 'package:plant_app/screens/login_page.dart';
import 'package:plant_app/screens/root.dart';
import 'package:plant_app/screens/sign_up/custom_form_field.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/build_custom_formfield_star.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  late ApiService apiService;
  late CustomerModel customerModel;
  bool isApiCalled = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();


  void _signup() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<SignupProvider>(context, listen: false);
      final response = await provider.signup(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        _firstNameController.text,
        _lastNameController.text,
      );

      if (response.containsKey('message')) {
        // Automatically login user after successful sign-up
        final loginProvider = Provider.of<LoginProvider>(context, listen: false);
        final loginResponse = await loginProvider.login(
          _usernameController.text,
          _passwordController.text,
        );

        if (loginResponse.containsKey('message')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RootPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loginResponse['error'] ?? 'Unknown error')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Unknown error')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'ثبت نام'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100.0,
            left: 43.0,
            child: SizedBox(
              width: size.width * 0.8,
              height: size.height * 0.8,
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        CustomFormField(
                          lableName: "نام:",
                          textDirection: TextDirection.rtl,
                          controller: _firstNameController,
                          validator: CustomValidator.fieldMustComplete,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        CustomFormField(
                          lableName: "نام خانوادگی:",
                          textDirection: TextDirection.rtl,
                          controller: _lastNameController,
                          validator: CustomValidator.fieldMustComplete,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        CustomFormField(
                          lableName: "نام کاربری:",
                          textDirection: TextDirection.ltr,
                          controller: _usernameController,
                          validator: CustomValidator.fieldMustComplete,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        CustomFormField(
                          lableName: "ایمیل:",
                          textDirection: TextDirection.ltr,
                          controller: _emailController,
                          validator: CustomValidator.emailValidator,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        CustomFormField(
                          lableName: "پسورد:",
                          obsecuretext: true,
                          textDirection: TextDirection.ltr,
                          controller: _passwordController,
                          validator: CustomValidator.passwordValidator,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Consumer<SignupProvider>(
                              builder: (context, provider, child) {
                                return provider.isLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                        onPressed: _signup,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Constant.primaryColor,
                                          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)
                                        ),
                                        child: const Text(
                                          "ثبت نام",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Yekan Bakh',
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      );
                              },
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            ElevatedButton(
                              onPressed: (){
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return const LoginPage();
                                    },
                                  )
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                side: BorderSide(width: 2, color: Constant.primaryColor),
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)
                              ),
                              child: Text(
                                "قبلا ثبت نام کردی؟",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Constant.primaryColor,
                                  fontFamily: 'Yekan Bakh',
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}