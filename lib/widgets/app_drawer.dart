import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello Friend!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Orders'),
            onTap: () => Navigator.of(context).pushReplacementNamed('order'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manager Product'),
            onTap: () =>
                Navigator.of(context).pushReplacementNamed('userProduct'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Log out'),
            onTap: () {
              Provider.of<Auth>(context, listen: false).logout();
              // Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
