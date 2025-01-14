import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';
import 'package:plant_app/widgets/build_custom_formfield.dart';
import 'package:plant_app/widgets/build_custom_formfield_star.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPlantsScreen extends StatefulWidget {
  const AddPlantsScreen({super.key});

  @override
  State<AddPlantsScreen> createState() => _AddPlantsScreenState();
}

class _AddPlantsScreenState extends State<AddPlantsScreen> {

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://45.156.23.34:8000'));
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _plantNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _humidityController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sizeController = TextEditingController();

   @override
  void dispose() {
    _plantNameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _humidityController.dispose();
    _temperatureController.dispose();
    _descriptionController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPhoto(int plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: '$plantId.png',
        ),
      });

      final response = await _dio.post(
        '/images/upload_photo/$plantId',
        data: formData,
        options: Options(
          headers: {
            'session_id': sessionId,
          },
          contentType: 'application/json',
        ),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload photo')),
      );
    }
  }

  Future<void> submitPlant() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      final plant = Plant(
        plantName: _plantNameController.text,
        price: int.parse(_priceController.text),
        category: _categoryController.text,
        humidity: int.parse(_humidityController.text),
        temperature: _temperatureController.text,
        description: _descriptionController.text,
        size: _sizeController.text,
        isFavorated: false,
      );
      try {
        final response = await _dio.post(
          '/plants/add',
          data: plant.toJson(),
          options: Options(
            headers: {'session_id': sessionId},
          ),
        );
        final responseData = response.data;
        if (responseData != null && responseData['plantid'] != null) {
          final plantId = responseData['plantid'];
          await _uploadPhoto(plantId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('گیاه با موفقیت اضافه شد')),
          );
        }
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مشکلی وجود دارد. گیاه اضافه نشد :(')),
        );
      }
    }
  }

   void _clearForm() {
    _formKey.currentState!.reset();
    _plantNameController.clear();
    _priceController.clear();
    _categoryController.clear();
    _humidityController.clear();
    _temperatureController.clear();
    _descriptionController.clear();
    _sizeController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'اضافه کردن گیاه'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                margin: const EdgeInsets.only(top: 50.0),
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    BuildCustomFormField(
                      controller: _plantNameController,
                      keyboardType: TextInputType.text,
                      labelName: "نام گیاه:",
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 5),
                    BuildCustomFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      labelName: "قیمت:",
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 5),
                    BuildCustomFormField(
                      controller: _categoryController,
                      keyboardType: TextInputType.text,
                      labelName: "گروه:",
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 5),
                    BuildCustomFormField(
                      controller: _humidityController,
                      keyboardType: TextInputType.number,
                      labelName: "رطوبت هوا:",
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 5),
                    BuildCustomFormField(
                      controller: _temperatureController,
                      keyboardType: TextInputType.number,
                      labelName: "دمای نگه‌داری:",
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 5),
                    BuildCustomFormField(
                      maxlines: 5,
                      minlines: 1,
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      labelName: "توصیف:",
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 5),
                    BuildCustomFormField(
                      controller: _sizeController,
                      keyboardType: TextInputType.text,
                      labelName: "اندازه:",
                      validator: CustomValidator.fieldMustComplete,
                    ),
                    const SizedBox(height: 15),
                    _selectedImage != null
                    ? Image.file(_selectedImage!)
                    : GestureDetector(
                      onTap: _pickImage,
                      child: Image.asset("assets/images/add_plant.png"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(width: 2, color: Constant.primaryColor),
                        overlayColor: Constant.primaryColor,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0)
                      ),
                      onPressed: submitPlant,
                      child: Text(
                        'ذخیره',
                        style: TextStyle(
                          color: Constant.primaryColor,
                          fontFamily: 'Yekan Bakh',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700
                        ),
                      ),
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