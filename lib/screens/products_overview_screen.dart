import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/product_gird.dart';

enum FilterOption { FavoriteOnly, ShowAll }

class ProductsOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop App'),
        actions: [
          _filter(productsProvider),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              value: cart.itemLength.toString(),
              child: ch,
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () => Navigator.of(context).pushNamed('cart'),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts(false),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.error != null) {
              return Text('Fails.');
            } else {
              return ProductGrid();
            }
          }
        },
      ),
    );
  }

  Widget _filter(productsProvider) => PopupMenuButton(
        onSelected: (FilterOption value) {
          if (value == FilterOption.FavoriteOnly) {
            productsProvider.showFavoriteOnly(true);
          } else {
            productsProvider.showFavoriteOnly(false);
          }
        },
        icon: Icon(Icons.more_vert),
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text('favorite only'),
            value: FilterOption.FavoriteOnly,
          ),
          PopupMenuItem(
            child: Text('show all'),
            value: FilterOption.ShowAll,
          ),
        ],
      );
}
