// lib/features/home/presentation/placeholder_pages.dart

import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Ini adalah halaman $title', style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}

// Halaman placeholder spesifik
class MaterialSpringbedPage extends StatelessWidget {
  const MaterialSpringbedPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(title: 'Material Springbed');
}

class MaterialSofaPage extends StatelessWidget {
  const MaterialSofaPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(title: 'Material Sofa');
}

class MaterialSpringbedAccessoriesPage extends StatelessWidget {
  const MaterialSpringbedAccessoriesPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(title: 'Material Springbed & Sofa');
}

class MachineSparepartPage extends StatelessWidget {
  const MachineSparepartPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(title: 'Mesin & Sparepart');
}

class FurniturePage extends StatelessWidget {
  const FurniturePage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(title: 'Furniture');
}