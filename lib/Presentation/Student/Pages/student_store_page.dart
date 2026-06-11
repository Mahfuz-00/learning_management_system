import 'package:flutter/material.dart';
import '../Widgets/student_store_widgets.dart';
import 'dart:developer';

class StudentStorePage extends StatelessWidget {
  const StudentStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    log('UI: StudentStorePage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6, // Placeholder
        itemBuilder: (context, index) {
          return StoreItemCard(
            title: 'Learning Book ${index + 1}',
            price: '\$${(index + 1) * 10}.99',
            imageUrl: '',
          );
        },
      ),
    );
  }
}
