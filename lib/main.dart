import 'package:flutter/material.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/order_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

import 'package:provider/provider.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products([]),
            update: (ctx, auth, prevProducts) {
              return Products(
                  prevProducts?.items == null ? [] : prevProducts.items,
                  authToken: auth.token,
                  userId: auth.userId);
            }),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders([]),
            update: (ctx, auth, prevOrders) {
              return Orders(prevOrders?.orders ?? [],
                  authToken: auth.token, userId: auth.userId);
            }),
      ],
      child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Shop App',
                theme: ThemeData(
                    primaryColor: Colors.purple,
                    accentColor: Colors.deepOrange,
                    pageTransitionsTheme: PageTransitionsTheme(builders: {
                      TargetPlatform.android: CustomRoutePageTransition(),
                      TargetPlatform.iOS: CustomRoutePageTransition(),
                    }),
                    fontFamily: 'Lato'),
                home: auth.isAuth
                    ? ProductsOverviewScreen()
                    : FutureBuilder(
                        future: auth.tryToLogin(),
                        builder: (BuildContext context,
                                AsyncSnapshot snapshot) =>
                            snapshot.connectionState == ConnectionState.waiting
                                ? SplashScreen()
                                : AuthScreen(),
                      ),
                routes: {
                  'productOver': (context) => ProductsOverviewScreen(),
                  'productDetail': (context) => ProductDetailScreen(),
                  'cart': (context) => CartScreen(),
                  'order': (context) => OrdersScreen(),
                  'userProduct': (context) => UserProductScreen(),
                  'editProduct': (context) => EditProductScreen(),
                },
              )),
    );
  }
}
