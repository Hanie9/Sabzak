class CustomerDetailsModel {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? avatarURL;
  Billing? billing;
  Shipping? shipping;

  CustomerDetailsModel({
    this.firstName,
    this.lastName,
    this.email,
    this.avatarURL,
    this.billing,
    this.shipping,
  });

  CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    avatarURL = json['avatar_url'];
    billing = json['billing'] != null ? Billing.fromJson(json['billing']) : null;
    shipping = json['shipping'] != null ? Shipping.fromJson(json['shipping']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['billing'] = billing?.toJson();
    data['shipping'] = shipping?.toJson();
    return data;
  }
}
// NABEGHEHA.COM
class Billing {
  String? firstName;
  String? lastName;
  String? address1;
  String? address2;
  String? city;
  String? postCode;
  String? country;
  String? email;
  String? phone;

  Billing({
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.postCode,
    this.country,
    this.email,
    this.phone,
  });

  Billing.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    postCode = json['postCode'];
    country = json['country'];
    email = json['email'];
    phone = json['phone'];
  }
// NABEGHEHA.COM
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['city'] = city;
    data['postCode'] = postCode;
    data['country'] = country;
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}

class Shipping {
  String? firstName;
  String? lastName;
  String? address1;
  String? address2;
  String? city;
  String? postCode;
  String? country;
  String? phone;

  Shipping({
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.postCode,
    this.country,
    this.phone,
  });
  Shipping.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    postCode = json['postcode'];
    country = json['country'];
    phone = json['phone'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['city'] = city;
    data['postcode'] = postCode;
    data['country'] = country;
    data['phone'] = phone;
    return data;
  }
}