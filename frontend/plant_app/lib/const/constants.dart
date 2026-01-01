import 'package:flutter/material.dart';


class Serverinfo{

  static String baseURL = 'http://45.156.23.34:8888/';

  // API end points
  static String plantURL = 'plants';
  static String createuserURL = 'sign_up';
  static String loginuserURL = 'login';
}

class Constant{
  static Color primaryColor = const Color(0xFF296e48);
  static Color blackColor = Colors.black54;
}

// mixin AppLocale {

//   static const String radsplash = 'rad';
//   static const String titleOne = 'one';
//   static const String titleTwo = 'two';
//   static const String titleThree = 'three';
//   static const String descriptionOne = 'done';
//   static const String descriptionTwo = 'dtwo';
//   static const String descriptionThree = 'dthree';
//   static const String apartemani = 'apartemani';
//   static const String pishnahadi = 'pishnahadi';
//   static const String mahaleKar = 'Kar';
//   static const String baghche = 'bagh';
//   static const String sammi = 'sammi';
//   static const String search = 'search';
//   static const String newplants = 'new';
//   static const String sanaz = 'sanaz';
//   static const String myprofile = 'mypro';
//   static const String setting = 'setting';
//   static const String notifications = 'notif';
//   static const String shabakeEjtemaee = 'shabake';
//   static const String exit = 'exit';
//   static const String home = 'home';
//   static const String alaghemandi = 'alaghe';
//   static const String sabad = 'sabad';
//   static const String profile = 'profile';
//   static const String theme = 'theme';
//   static const String aboutus = 'aboutus';
//   static const String language = 'language';
//   static const String feedback = 'feedback';
//   static const String cart = 'cart';
//   static const String jamKol = 'jamKol';
//   static const String andazeGol = 'andazaGol';
//   static const String humidity = 'humidity';
//   static const String dama = 'dama';
//   static const String afzoodanBeSabad = 'afzoodan';
//   static const String hazfAzSabad = 'hazf';
//   static const String descriptionAfzoodan = 'descriptionafzoodan';
//   static const String descriptionHazf = 'descriptionHazf';
//   static const String favorite = 'favorite';
//   static const String scan = 'scan';
//   static const String desMamooriat = 'desMamooriat';
//   static const String mamooriat = 'mamooriat';
//   static const String maCheKasaniHastim = 'maCheKasaniHastim';
//   static const String desMaCheKasaniHastim = 'desMaCheKasaniHastim';
//   static const String yourfeedbacks = 'yourfeedbacks';
//   static const String titreBazkhord = 'titreBazkhord';
//   static const String lableBazkhord = 'lableBazkhord';
//   static const String errorBazkhord = 'errorBazkhord';
//   static const String matnesnackbar = 'matnesnackbar';
//   static const String ersal = 'ersal';
//   static const String themes = 'themes';
//   static const String darkTheme = 'darkTheme';
//   static const String titleLanguage = 'Language';



//   static const Map<String, dynamic> EN = {
//     radsplash : 'reject',
//     titleOne : 'Understand plants better than before',
//     titleTwo : 'Get to know new plants',
//     titleThree : 'One flower does not make spring, plant flowers',
//     descriptionOne : 'You can get information about maintaining flowers and plants',
//     descriptionTwo : 'Do you like black rose or rose? You can find it here',
//     descriptionThree : 'You can find any flower you need in this application',
//     pishnahadi : '| Suggested |',
//     apartemani : '| Apartment |',
//     mahaleKar : '| Workplace |',
//     baghche : '| Garden flower |',
//     sammi : '| Posionous flower |',
//     search : 'Search ...',
//     newplants : 'New plants',
//     sanaz : 'Sanaz Amini',
//     myprofile : 'My profile',
//     setting : 'Setting',
//     notifications : 'Notifications',
//     shabakeEjtemaee : 'Social Networks',
//     exit : 'Exit',
//     home : 'Home',
//     alaghemandi : 'Favorites',
//     sabad : 'Cart',
//     profile : 'Profile',
//     language : 'Language',
//     theme : 'Theme',
//     aboutus : 'About us',
//     feedback : 'Your feedbacks',
//     cart : 'The shopping cart is empty :(',
//     jamKol : 'Total',
//     andazeGol : 'Plant size',
//     humidity : 'Humidity',
//     dama : 'Storage temperature',
//     afzoodanBeSabad : 'Add to cart',
//     hazfAzSabad : 'Remove from cart',
//     descriptionAfzoodan : '%a plant has been successfully added to the shopping cart',
//     descriptionHazf : '%a plant has been successfully removed from the shopping cart',
//     favorite : 'Apparently you were not interested in anything🙁',
//     scan : 'Click to scan the plant',
//     mamooriat : 'Our mission',
//     desMamooriat : 'Our mission is to help people discover the beauty of plants and the benefits they can bring to our daily lives.',
//     maCheKasaniHastim : 'Who are we?',
//     desMaCheKasaniHastim : 'We are a team of plant enthusiasts who believe in the power of greenery to bring positivity and balance to our lives.',
//     yourfeedbacks : 'Your feedbacks',
//     titreBazkhord : 'We value your feedback',
//     lableBazkhord : 'Enter your feedback',
//     errorBazkhord : 'Please enter your feedback',
//     matnesnackbar : 'Processing',
//     ersal : 'Submit',
//     themes : 'Themes',
//     darkTheme : 'Dark theme',
//     titleLanguage : 'Languages',
    
//   };
//   static Map<String, dynamic> IR = {
//     radsplash : 'رد کردن',
//     titleOne : 'گیاهان را بهتر از قبل درک کن',
//     titleTwo : 'با گیاهان جدید آشنا شو',
//     titleThree : 'با یک گل بهار نمیشود‌‌,گل بکار',
//     descriptionOne : 'درمورد نگهداری گل و گیاهان میتوانی اطلاعات کسب کنی',
//     descriptionTwo : 'رز مشکی یا گل رز دوست داری؟ اینجا میتونی پیداش کنی',
//     descriptionThree : 'هر گلی نیاز داشته باشید در این اپلیکیشن پیدا میکنید',
//     pishnahadi : '| پیشنهادی |',
//     apartemani : '| آپارتمانی |',
//     mahaleKar : '| محل‌کار |',
//     baghche : '| گل باغچه ای |',
//     sammi : '| گل سمی |',
//     search : 'جستجو ...',
//     newplants : 'گیاهان جدید',
//     sanaz : 'ساناز امینی',
//     myprofile : 'پروفایل من',
//     setting : 'تنظیمات',
//     notifications : 'اطلاع رسانی‌ها',
//     shabakeEjtemaee : 'شبکه‌های اجتماعی',
//     exit : 'خروج',
//     home : 'خانه',
//     alaghemandi : 'علاقه‌مندی‌ها',
//     sabad : 'سبد‌خرید',
//     profile : 'پروفایل',
//     language : 'زبان',
//     theme : 'زمینه',
//     aboutus : 'درباره ما',
//     feedback : 'بازخورد شما',
//     cart : 'سبد خرید تار عنکبوت بسته است :(',
//     jamKol : 'جمع کل',
//     andazeGol : 'اندازه گیاه',
//     humidity : 'رطوبت‌هوا',
//     dama : 'دمای‌نگه‌داری',
//     afzoodanBeSabad : 'افزودن‌به‌سبد‌خرید',
//     hazfAzSabad : 'حذف‌از‌سبد‌خرید',
//     descriptionAfzoodan : 'گیاه %a با موفقیت به سبد خرید اضافه شد',
//     descriptionHazf : 'گیاه %a با موفقیت از سبد خرید حذف شد',
//     favorite : 'ظاهرا به هیچی علاقه نداشتی :-|',
//     scan : 'برای اسکن گیاه کلیک کنید',
//     mamooriat : 'ماموریت ما',
//     desMamooriat : 'ماموریت ما کمک به مردم برای کشف زیبایی گیاهان و مزایایی است که آنها می توانند به زندگی روزمره ما بیاورند.',
//     maCheKasaniHastim : 'ما چه کسانی هستیم؟',
//     desMaCheKasaniHastim : 'ما تیمی از علاقه مندان به گیاهان هستیم که به قدرت سبز برای آوردن انرژی مثبت و تعادل به زندگی اعتقاد داریم.',
//     yourfeedbacks : 'بازخورد‌های شما',
//     titreBazkhord : 'ما برای بازخورد شما ارزش قائل هستیم',
//     lableBazkhord : 'بازخورد خود را وارد کنید',
//     errorBazkhord : 'لطفا بازخورد خود را وارد کنید',
//     matnesnackbar : 'در حال پردازش',
//     ersal : 'ارسال',
//     themes : 'زمینه‌ها',
//     darkTheme : 'زمینه سیاه',
//     titleLanguage : 'زبان‌ها',
//   };
// }