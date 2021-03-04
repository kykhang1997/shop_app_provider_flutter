import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.of(context).pushNamed('editProduct'))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts(true),
        builder: (BuildContext context, AsyncSnapshot snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        Provider.of<Products>(context, listen: false)
                            .fetchAndSetProducts(true),
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Consumer<Products>(
                          builder: (context, productsData, child) =>
                              ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (context, index) => Column(
                              children: [
                                UserProductItem(
                                  id: productsData.items[index].id,
                                  title: productsData.items[index].title,
                                  imageUrl: productsData.items[index].imageUrl,
                                ),
                                Divider()
                              ],
                            ),
                          ),
                        )),
                  ),
      ),
    );
  }
}
