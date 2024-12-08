import 'package:flutter/material.dart';
import 'package:plant_app/const/constants.dart';
import 'package:plant_app/screens/root.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final PageController _pageController = PageController(initialPage: 0);
  int currentindex = 0;

  Widget _indicator(bool isActive){
    return AnimatedContainer(
      duration: const Duration(microseconds: 300),
      height: 10.0,
      width: isActive ? 20.0 : 8.0,
      margin: const EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        color: Constant.primaryColor,
        borderRadius: BorderRadius.circular(5.0)
      ),
    );
  }

  List<Widget> _buildindicator(){
    List<Widget> indicators = [];

    for(int i=0; i<3 ; i++){
      if(currentindex == i){
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }
    return indicators;
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int value) {
              setState(() {
                currentindex = value;
              });
            },
            children: const [
              CreatePage(
                image: 'assets/images/1_1.png',
                title: 'گیاهان را بهتر از قبل درک کن',
                description:'درمورد نگهداری گل و گیاهان میتوانی اطلاعات کسب کنی' ,
              ),
              CreatePage(
                image: 'assets/images/6_6.png',
                title: 'با گیاهان جدید آشنا شو',
                description: 'رز مشکی یا گل رز دوست داری؟ اینجا میتونی پیداش کنی',
              ),
              CreatePage(
                image: 'assets/images/5_5.png',
                title: 'با یک گل بهار نمیشود‌‌,گل بکار',
                description: 'هر گلی نیاز داشته باشید در این اپلیکیشن پیدا میکنید',
              ),
            ],
          ),
          Positioned(
            bottom: 80.0,
            left: 30.0,
            child: Row(
              children:_buildindicator(),
            ),
          ),
          Positioned(
            bottom: 80.0,
            right: 30.0,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constant.primaryColor,
              ),
              child: IconButton(
                onPressed: (){
                  setState(() {
                    if(currentindex < 2){
                      currentindex += 1;
                      if(currentindex < 3){
                        _pageController.nextPage(duration: const Duration(microseconds: 100), curve: Curves.easeIn);
                      }
                    } else {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RootPage()));
                    }
                  });
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CreatePage extends StatelessWidget {

  final String image;
  final String title;
  final String description;


  const CreatePage({
    super.key, required this.image, required this.title, required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 350.0,
            child: Image.asset(image),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'iransans',
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
              color: Constant.primaryColor,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Yekan Bakh',
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }
}