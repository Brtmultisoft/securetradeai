import 'package:flutter/material.dart';

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> firstItems = [like, price, subscribe];

  static const like = MenuItem(text: 'Like', icon: Icons.thumb_up);
  static const price = MenuItem(text: 'Price', icon: Icons.currency_exchange);
  static const subscribe =
      MenuItem(text: 'Subscribe', icon: Icons.notifications);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.like:
        print("click like");
        break;
      case MenuItems.price:
         print("click price");
        break;
      case MenuItems.subscribe:
         print("click subscribe");
        break;
    }
  }
}
