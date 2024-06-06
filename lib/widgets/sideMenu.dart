import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget menulateral(BuildContext context){
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.deepPurple,
          ),
          child: Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            Navigator.pop(context); // Cierra el drawer
            // Lógica adicional si es necesario
          },
        ),
        ListTile(
          leading: Icon(Icons.star),
          title: Text('Second Page'),
          onTap: () {
            Navigator.pop(context); // Cierra el drawer
            // Lógica adicional si es necesario
          },
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Third Page'),
          onTap: () {
            Navigator.pop(context); // Cierra el drawer
            // Lógica adicional si es necesario
          },
        ),
      ],
    ),
  );
}