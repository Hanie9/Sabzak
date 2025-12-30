import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/widgets/build_custom_appbar.dart';

class AboutProjectPage extends StatelessWidget {
  const AboutProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const BuildCustomAppbar(appbarTitle: 'درباره ما'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'درباره پروژه',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Yekan Bakh",
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'این برنامه یک سیستم مدیریت فروش گیاهان است که به کاربران امکان جستجو، مشاهده و خرید گیاهان مختلف را می‌دهد.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: "iransans",
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'قسمت‌های مختلف برنامه',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Yekan Bakh",
                  ),
                ),
                const SizedBox(height: 15),
                _buildSection(
                  'صفحه اصلی',
                  'نمایش لیست گیاهان با امکان جستجو و فیلتر بر اساس دسته‌بندی',
                ),
                _buildSection(
                  'صفحه جزئیات گیاه',
                  'نمایش اطلاعات کامل گیاه شامل قیمت، توضیحات، رطوبت، دما و نظرات کاربران',
                ),
                _buildSection(
                  'سبد خرید',
                  'مدیریت سبد خرید با امکان افزودن، حذف و تغییر تعداد آیتم‌ها',
                ),
                _buildSection(
                  'پروفایل کاربر',
                  'مدیریت اطلاعات شخصی و مشاهده تاریخچه خریدها',
                ),
                _buildSection(
                  'صفحه ادمین',
                  'مدیریت گیاهان، کاربران، اطلاعیه‌ها و پشتیبان‌گیری از پایگاه داده',
                ),
                const SizedBox(height: 30),
                const Text(
                  'تهیه کنندگان',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Yekan Bakh",
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Constant.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDeveloper(
                        'حانیه نباتی',
                        'توسعه Frontend',
                      ),
                      const SizedBox(height: 15),
                      _buildDeveloper(
                        'امیرحسین حفیظی',
                        'توسعه Backend',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "Yekan Bakh",
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 16.0,
              fontFamily: "iransans",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloper(String name, String role) {
    return Row(
      children: [
        Icon(
          Icons.person,
          color: Constant.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Yekan Bakh",
                ),
              ),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "iransans",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

