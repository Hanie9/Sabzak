class ZarinpalRequest {
  Data? data;
  List<dynamic>? errors;

  ZarinpalRequest({
    this.data,
    this.errors,
  });

  ZarinpalRequest.fromJson(Map<String, dynamic> json) {
    data = Data.fromJson(json["data"]);
    errors = List<dynamic>.from(json["errors"].map((x) => x));
  }
}

class Data {
  Data({
    this.code,
    this.message,
    this.authority,
    this.feeType,
    this.fee,
  });

  int? code;
  String? message;
  String? authority;
  String? feeType;
  int? fee;

  Data.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    message = json["message"];
    authority = json["authority"];
    feeType = json["fee_type"];
    fee = json["fee"];
  }
}