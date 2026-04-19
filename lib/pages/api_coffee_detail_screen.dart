import 'package:flutter/material.dart';
import 'package:flutterproject/colors.dart';
import 'package:flutterproject/models/api_coffee_model.dart';

class ApiCoffeeDetailScreen extends StatelessWidget {
  final ApiCoffee coffee;

  const ApiCoffeeDetailScreen({super.key, required this.coffee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: xbackgroundColor,
      appBar: AppBar(
        title: Text(coffee.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              coffee.image,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 260,
                color: Colors.grey.shade300,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            coffee.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text(coffee.isHot ? 'Sıcak' : 'Soğuk'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Açıklama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            coffee.description.isEmpty
                ? 'Bu kahve için açıklama bulunmuyor.'
                : coffee.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'İçindekiler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...coffee.ingredients.map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.coffee),
                title: Text(item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}