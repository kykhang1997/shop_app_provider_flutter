import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import 'product.dart';

const url = 'https://shopapp-87fa8-default-rtdb.firebaseio.com/products.json';
// JSON = JavaScript Object Notation;

class Products with ChangeNotifier {
  List<Product> _items = [];
  bool _showfavoriteOnly = false;

  final String authToken;
  final String userId;

  Products(this._items, {this.userId, this.authToken});

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  void showFavoriteOnly(bool value) {
    _showfavoriteOnly = value;
    notifyListeners();
  }

  Future<void> fetchAndSetProducts([bool filterbyUser = false]) async {
    try {
      final filterString =
          filterbyUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
      final res = await http.get('$url?auth=$authToken$filterString');
      final extratedData = jsonDecode(res.body) as Map<String, dynamic>;
      if (extratedData['error'] != null) {
        print('fails');
        return;
      }
      final urlFavorite =
          'https://shopapp-87fa8-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final resFavorite = await http.get(urlFavorite);
      final favoriteData = json.decode(resFavorite.body);
      final List<Product> loadedProduct = [];
      extratedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
            creatorId: userId,
            imageUrl: prodData['imageUrl']));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final res = await http.post('$url?auth=$authToken',
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'isFavorite': product.isFavorite,
            'imageUrl': product.imageUrl,
            'creatorId': userId
          }));
      final newProduct = Product(
          id: json.decode(res.body)['name'],
          price: product.price,
          title: product.title,
          description: product.description,
          creatorId: userId,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    try {
      final prodIndex = _items.indexWhere((element) => element.id == id);
      if (prodIndex >= 0) {
        final urlUpdate =
            'https://shopapp-87fa8-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
        await http.patch(urlUpdate,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            }));
        _items[prodIndex] = newProduct;
        notifyListeners();
      } else {
        print('...');
      }
    } catch (e) {}
  }

  Future<void> deleteProduct(String productId) async {
    final urlUpdate =
        'https://shopapp-87fa8-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken';
    final existingProductIndex =
        _items.indexWhere((element) => element.id == productId);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final res = await http.delete(urlUpdate);
    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  // get items
  List<Product> get items {
    if (_showfavoriteOnly) {
      return _items.where((element) => element.isFavorite).toList();
    }
    return [..._items];
  }
}
