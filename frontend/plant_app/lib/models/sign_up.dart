class CustomerModel{
  String? email;
  String? username;
  String? password;

  CustomerModel({
    this.email,
    this.username,
    this.password,
  });

  Map<String,dynamic> tojson(){
    Map<String,dynamic> json = {};
    json.addAll({
      'email' : email,
      'username' : username,
      'password' : password,
    });
    return json;
  }
}