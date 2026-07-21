import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Bloc/store_bloc.dart';
import '../Widgets/student_store_widgets.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class StudentStorePage extends StatefulWidget {
  const StudentStorePage({super.key});

  @override
  State<StudentStorePage> createState() => _StudentStorePageState();
}

class _StudentStorePageState extends State<StudentStorePage> {
  @override
  void initState() {
    super.initState();
    context.read<StoreBloc>().add(LoadStoreItems());
  }

  @override
  Widget build(BuildContext context) {
    log('UI: StudentStorePage build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('LMS Store'),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              log('UI: Cart opened');
            },
          ),
        ],
      ),
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          if (state is StoreLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          } else if (state is StoreLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No items available in store right now.'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return StoreItemCard(
                  title: item.title,
                  price: '৳${item.price.toStringAsFixed(0)}',
                  imageUrl: item.thumbnail ?? '',
                );
              },
            );
          } else if (state is StoreError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
