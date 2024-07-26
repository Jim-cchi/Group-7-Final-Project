import 'package:flutter/material.dart';
import '../pages/pages.dart';
import '../pages/drawer_pages.dart';

class MyListTile extends StatelessWidget {
  const MyListTile({
    super.key,
    this.text = "test",
    this.subtitle = "",
    this.leadingIcon = Icons.person,
    this.trailingIcon, 
    this.trailingIconColor = Colors.white,
    this.onTap, // Add onTap callback
  });

  final String text;
  final String subtitle;
  final IconData leadingIcon;
  final IconData? trailingIcon;
  final Color trailingIconColor;
  final VoidCallback? onTap; // Define onTap callback
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leadingIcon, color: Colors.white,),
      title: Text(text, style: const TextStyle(color: Colors.white),),
      subtitle: subtitle != "" ? Text(subtitle, style: const TextStyle(color: Color.fromARGB(255, 112, 114, 114)),) : null,
      trailing: trailingIcon != null ? Icon(trailingIcon, color: trailingIconColor,) : const Icon(null),
      tileColor: const Color.fromARGB(255, 20, 20, 20),
      onTap: onTap ?? () { // Use the onTap callback if provided
        subtitle == "" 
          ? Navigator.push(context, MaterialPageRoute(builder: (context) => DrawerPages(text: text,)))
          : Navigator.push(context, MaterialPageRoute(builder: (context) => MyPersonChat(text: text,)),
        );
      },
    );
  }
}
