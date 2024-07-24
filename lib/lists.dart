import 'package:flutter/material.dart';
import 'dart:math';

class MyNamesList {
  final List<List> names = [
    ["Meera", getRandomMessage()],
    ["Padua", getRandomMessage()],
    ["Opulencia", getRandomMessage()],
    ["Orgua", getRandomMessage()],
    ["Terrones", getRandomMessage()],
    ["Longannisa Seller", getRandomMessage()],
    ["Meera", getRandomMessage()],
    ["Manic", getRandomMessage()],
    ["Anya", getRandomMessage()],
    ["Yakult", getRandomMessage()],
    ["Fuecoco", getRandomMessage()],
    ["Xbox Controller 360", getRandomMessage()],
    ["Adadis Nyek", getRandomMessage()],
    ["March 7th", getRandomMessage()],
    ["Jing Yuan", getRandomMessage()],
    ["Alchol Jug", getRandomMessage()],
    ["Gaulie", getRandomMessage()],
    ["Vinben Benvin", getRandomMessage()],
    ["Tsuitachi Nijuyoka", getRandomMessage()],
    ["Futsuka Hatsuka", getRandomMessage()],
    ["Mika Jyuyokka", getRandomMessage()],
    ["Yokka Kokonokotoka", getRandomMessage()],
    ["Itsuka Muika", getRandomMessage()],
    ["Nanoka Youka", getRandomMessage()],
  ];
  final List<List> communities = [
    ["Jesus Christ is God", getRandomMessage()],
    ["Dahyun - TWICE / 트와이스 - Fan group", getRandomMessage()],
    ["BatStateU Tambayan", getRandomMessage()],
    ["Phoenix Army", getRandomMessage()],
    ["We Fam", getRandomMessage()],
    ["CICS - BatStateU JPLPC-Malvar", getRandomMessage()],
    ["Froshies - BatState-U Malvar", getRandomMessage()],
    ["8N.Memes", getRandomMessage()],
  ];

  static String getRandomMessage() {
    List<String> messages = [
      "Hello there!",
      "What's up?",
      "How's it going?",
      "Nice to meet you!",
      "Howdy!",
      "Greetings!",
      "Hey!",
      "What's new?",
      "Good to see you!",
      "Yo!",
      "Good Morning!",
    ];
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }
}


class MyCircleAvatarList {
  final List<ImageProvider> images = [];

  MyCircleAvatarList() {
    int count = 24;
    for (var i = 0; i < count; i++) {
      images.add(getRandomImage());
    }
  }

  // Method to get a random image
  static ImageProvider getRandomImage() {
    List<ImageProvider> imageList = [
      const AssetImage('assets/1.jpg'),
      const AssetImage('assets/2.jpg'),
      const AssetImage('assets/3.jpg'),
      const AssetImage('assets/4.jpg'),
      const AssetImage('assets/5.jpg'),
      const AssetImage('assets/6.jpg'),
      const AssetImage('assets/7.jpg'),
      const AssetImage('assets/8.jpg'),
      const AssetImage('assets/9.jpg'),
      const AssetImage('assets/10.jpg'),
      const AssetImage('assets/11.jpg'),
      const AssetImage('assets/12.jpg'),
      const AssetImage('assets/13.jpg'),
      const AssetImage('assets/14.jpg'),
      const AssetImage('assets/15.jpg'),
      // Add paths to your images here
    ];

    final random = Random();
    return imageList[random.nextInt(imageList.length)];
  }
}
class MySquareAvatarList {
  final List<ImageProvider> images_ = [];

  MySquareAvatarList() {
    int count = 24;
    for (var i = 0; i < count; i++) {
      images_.add(getRandomImage());
    }
  }

  // Method to get a random image
  static ImageProvider getRandomImage() {

    List<ImageProvider> imageLists = [
      const AssetImage('assets/communities/16.jpg'),
      const AssetImage('assets/communities/17.jpg'),
      const AssetImage('assets/communities/18.jpg'),
      const AssetImage('assets/communities/19.png'),
      const AssetImage('assets/communities/20.jpg'),
      const AssetImage('assets/communities/21.jpg'),
      const AssetImage('assets/communities/23.jpg'),
      const AssetImage('assets/communities/24.png'),
     
      // Add paths to your images here
    ];

    final random = Random();
    return imageLists[random.nextInt(imageLists.length)];
  }
}

