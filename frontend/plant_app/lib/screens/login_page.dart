import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/sign_up.dart';
import 'package:plant_app/providers/login_provider.dart';
import 'package:plant_app/screens/root.dart';
import 'package:plant_app/screens/sign_up/sign_up_page.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/build_custom_formfield.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late ApiService apiService;
  late CustomerModel customerModel;
  bool isApiCalled = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  void _login() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<LoginProvider>(context, listen: false);
      final response = await provider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (response.containsKey('message')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RootPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Unknown error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'ورود به برنامه'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 50.0,
            right: 0.0,
            child: Image.asset('assets/images/login_page.png'),
          ),
          Positioned(
            top: 250.0,
            left: 20.0,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: SizedBox(
                width: size.width * 0.8,
                height: size.height * 0.8,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30.0,),
                        BuildCustomFormField(
                          controller: _usernameController,
                          labelName: 'نام کاربری',
                          validator: CustomValidator.fieldMustComplete,
                          formFieldtextDirection: TextDirection.ltr,
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        BuildCustomFormField(
                          controller: _passwordController,
                          labelName: 'پسورد',
                          validator: CustomValidator.passwordValidator,
                          formFieldtextDirection: TextDirection.ltr,
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        Row(
                          children: [
                            Consumer<LoginProvider>(
                            builder: (context, provider, child) {
                              return provider.isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      onPressed: _login,
                                      child: const Text('Login'),
                                    );
                            },
                          ),
                            const SizedBox(
                              width: 20.0,
                            ),
                            _buildNeedRegisterButton(context),
                          ],
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        isApiCalled ? const Text(
                          'لطفا منتظر بمانید ...',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Yekan Bakh'
                          ),
                        ) : const Text(''),
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

  ElevatedButton _buildNeedRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        Navigator.of(context, rootNavigator: true).pushReplacement(
          CupertinoPageRoute(
            builder: (context) {
              return const SignupPage();
            },
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Constant.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)
      ),
      child: const Text(
        "اکانت نداری؟",
        style: TextStyle(
          fontFamily: 'Yekan Bakh',
          fontSize: 15.0,
        ),
      ),
    );
  }
}