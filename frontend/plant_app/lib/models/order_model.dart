import 'package:plant_app/models/customer_details_model.dart';
import 'package:shamsi_date/shamsi_date.dart';

class OrderModel {
  int? customerId;
  String? paymentMethod;
  String? paymentMethodTitle;
  bool? setPaid;
  String? transactionId;
  List<LineItems>? lineItems;
  int? orderId;
  String? orderNumber;
  String? status;
  Jalali? orderDate;
  Shipping? shipping;
  Billing? billing;

  OrderModel({
    this.customerId,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.setPaid,
    this.transactionId,
    this.lineItems,
    this.orderId,
    this.orderNumber,
    this.status,
    this.orderDate,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    orderId = json['id'];
    orderNumber = json['order_key'];
    status = json['status'];
    orderDate = DateTime.parse(json['date_created']).toJalali();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['customer_id'] = customerId;
    data['payment_method'] = paymentMethod;
    data['payment_method_title'] = paymentMethodTitle;
    data['set_paid'] = setPaid;
    data['transaction_id'] = transactionId;
    data['shipping'] = shipping!.toJson();
    data['billing'] = billing!.toJson();
    if (lineItems != null) {
      data['line_items'] = lineItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LineItems {
  int? productId;
  int? quantity;
  int? variationId;

  LineItems({
    this.productId,
    this.quantity,
    this.variationId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['product_id'] = productId;
    data['quantity'] = quantity;
    if (variationId != null) {
      data['variation_id'] = variationId;
    }
    return data;
  }
}