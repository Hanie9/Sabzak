import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/admin_page.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/build_custom_formfield.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isAdmin = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _apiService.createUserByAdmin(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          isAdmin: _isAdmin,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('کاربر با موفقیت ایجاد شد'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => const AdminScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطا: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'ایجاد کاربر جدید'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BuildCustomFormField(
                  controller: _firstNameController,
                  labelName: 'نام:',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا نام را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                BuildCustomFormField(
                  controller: _lastNameController,
                  labelName: 'نام خانوادگی:',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا نام خانوادگی را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                BuildCustomFormField(
                  controller: _usernameController,
                  labelName: 'نام کاربری:',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا نام کاربری را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                BuildCustomFormField(
                  controller: _emailController,
                  labelName: 'ایمیل:',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا ایمیل را وارد کنید';
                    }
                    if (!value.contains('@')) {
                      return 'ایمیل معتبر نیست';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                BuildCustomFormField(
                  controller: _passwordController,
                  labelName: 'رمز عبور:',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا رمز عبور را وارد کنید';
                    }
                    if (value.length < 8) {
                      return 'رمز عبور باید حداقل 8 کاراکتر باشد';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  title: const Text(
                    'دسترسی ادمین',
                    style: TextStyle(fontFamily: 'Yekan Bakh'),
                  ),
                  value: _isAdmin,
                  onChanged: (value) {
                    setState(() {
                      _isAdmin = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constant.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ایجاد کاربر',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Yekan Bakh',
                            fontSize: 18,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

