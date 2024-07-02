import 'package:flutter/material.dart';
import '../pages/pages.dart';
import '../pages/drawer_pages.dart';

class MyHighlightListTile extends StatelessWidget {
  const MyHighlightListTile({
    super.key,
     this.text = "test",
      this.subtitle = "",
       this.leadingIcon = Icons.person,
        this.trailingIcon, 
          this.trailingIconColor = Colors.white,
        });

  final String text;
  final String subtitle;
  final IconData leadingIcon;
  final IconData? trailingIcon;
  final Color trailingIconColor;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
         leading: Icon(leadingIcon, color: Colors.white, size: 50,),
         title: Text(text, style: const TextStyle(color: Colors.white),),
         subtitle: subtitle != "" ? Text(subtitle, style: const TextStyle(color: Color.fromARGB(255, 112, 114, 114)),) : null,
         trailing: trailingIcon != null ? Icon(trailingIcon, color: trailingIconColor,) : const Icon(null),
         tileColor: const Color.fromARGB(255, 20, 20, 20),
         onTap: () { 
          subtitle == "" ? Navigator.push(context, MaterialPageRoute(builder: (context) => DrawerPages(text: text,)))
          : Navigator.push(context, MaterialPageRoute(builder: (context) => MyPersonChat(text: text,)),
          );
         },
        ),
        const ListTile(
          tileColor: Color.fromARGB(255, 20, 20, 20),
          leading: Icon(Icons.person, color: Color.fromARGB(255, 112, 114, 114)),
          title: TextField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              hintText: "Send Message..",
              hintStyle: TextStyle(color: Color.fromARGB(255, 112, 114, 114)),
          )
          ),
          trailing: Icon(Icons.favorite, color: Color.fromARGB(255, 112, 114, 114),),
        )
      ],
    );
  }
}



