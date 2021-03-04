import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' as ord;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  OrderItem({Key key, this.order}) : super(key: key);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isShowExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isShowExpanded
          ? min(widget.order.products.length * 20.0 + 115, 200)
          : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Consumer<ord.Orders>(
          builder: (ctx, od, _) => Column(
            children: [
              ListTile(
                title: Text('\$${widget.order.amount}'),
                subtitle: Text(DateFormat('dd/MM/yyyy - hh:mm')
                    .format(widget.order.dateTime)),
                trailing: IconButton(
                  icon: Icon(
                      _isShowExpanded ? Icons.expand_more : Icons.expand_less),
                  onPressed: () => setState(() {
                    _isShowExpanded = !_isShowExpanded;
                  }),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                height: _isShowExpanded
                    ? min(widget.order.products.length * 20.0 + 15, 100)
                    : 0,
                child: ListView(
                  children: widget.order.products
                      .map((e) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.title,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${e.quantity}x \$${e.price}',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              )
                            ],
                          ))
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
