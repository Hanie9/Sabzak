import 'package:flutter/material.dart' show ChangeNotifier;

class LoaderProvider with ChangeNotifier{
  bool _isApiCalled = false;
  bool get isApiCalled => _isApiCalled;

  setLoadingStatus(bool status){
    _isApiCalled = status;
    notifyListeners();
    
  }
}