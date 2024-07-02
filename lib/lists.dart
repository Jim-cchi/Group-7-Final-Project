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
  final List<Color> colors = [];


  MyCircleAvatarList(){
    int count = 20;
    for (var i = 0; i < count; i++) {
      colors.add(getRandomColor());
    }
  }
  
  static Color getRandomColor() {
    List<Color> colors = [
      const Color.fromARGB(255, 33, 148, 241),
      const Color.fromARGB(255, 78, 166, 239),
      const Color.fromARGB(255, 40, 134, 211),
      const Color.fromARGB(255, 17, 113, 191),
    ];
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }
}

