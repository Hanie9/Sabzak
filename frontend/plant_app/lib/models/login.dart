class LoginResponseModel{
  bool? success;
  int? statuscode;
  String? code;
  String? message;
  Data? data;

  LoginResponseModel({
    this.success,
    this.statuscode,
    this.code,
    this.message,
    this.data,
  });

  LoginResponseModel.fromJson(Map<String,dynamic> json){
    success = json['success'];
    statuscode = json['statusCode'];
    code = json['code'];
    message = json['message'];
    if(json['success'] == true){
      data = Data.fromJson(json['data']);
    }
  }

  Map<String, dynamic> tojson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['statusCode'] = statuscode;
    data['code'] = code;
    data['message'] = message;

    if(data[success] == true){
      data['data'] = this.data?.tojson();
    }
    return data;
  }

}

class Data{
  String? sessionId;
  int? id;
  String? username;
  String? firstName;
  String? lastName;

  Data({
    this.sessionId,
    this.id,
    this.username,
    this.firstName,
    this.lastName,
  });

  Data.fromJson(Map<String,dynamic> json){
    sessionId = json['session_id'];
    id = json['userid'];
    username = json['username'];
    firstName = json['firstName'];
    lastName = json['lastName'];
  }

  Map<String,dynamic> tojson(){
    final Map<String,dynamic> data = <String,dynamic>{};
    data['session_id'] = sessionId;
    data['userid'] = id;
    data['username'] = username;
    data['firstName'] = firstName;
    data['lastName'] = lastName;

    return data;
  }
}