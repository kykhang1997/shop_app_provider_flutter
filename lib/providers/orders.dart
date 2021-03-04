import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

const url = 'https://shopapp-87fa8-default-rtdb.firebaseio.com/order.json';

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this._orders, {this.authToken, this.userId});

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrder() async {
    try {
      final res = await http.get(
          'https://shopapp-87fa8-default-rtdb.firebaseio.com/order/$userId.json?auth=$authToken');
      List<OrderItem> loadedOrder = [];
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      extractedData.forEach((orderId, orderData) {
        loadedOrder.add(OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: (orderData['products'] as List<dynamic>)
                .map((e) => CartItem(
                    id: e['id'],
                    title: e['title'],
                    quantity: e['quantity'],
                    price: e['price']))
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime'])));
      });
      _orders = loadedOrder;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    try {
      final timeNow = DateTime.now();
      final res = await http.post(
          'https://shopapp-87fa8-default-rtdb.firebaseio.com/order/$userId.json?auth=$authToken',
          body: json.encode({
            'amount': total,
            'dateTime': timeNow.toIso8601String(),
            'products': cartProducts
                .map((e) => {
                      'id': e.id,
                      'title': e.title,
                      'quantity': e.quantity,
                      'price': e.price
                    })
                .toList()
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(res.body)['name'],
              amount: total,
              products: cartProducts,
              dateTime: timeNow));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}
