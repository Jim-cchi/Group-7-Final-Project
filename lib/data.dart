class Person{
  final String name;
  final String image;

  Person({required this.name, required this.image});

  final List<Person> people = [
    Person(name: "Meera", image: "assets/images/meera.jpg"),
  ];
}
