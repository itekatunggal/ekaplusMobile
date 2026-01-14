// lib/features/home/presentation/widgets/all_products_modal.dart

import 'package:ekaplus_ekatunggal/constant.dart';

import 'package:flutter/material.dart';
// import '../placeholder_pages.dart';

class AllProductsModal extends StatelessWidget {
  // Ganti dengan halaman target yang
  const AllProductsModal({super.key});

  // Data kategori lengkap dari gambar "Semua Produk"
  final List<Map<String, dynamic>> _allCategories = const [
    {'header': 'Kategori'},
    {
      'name': 'Material Springbed',
      'desc': 'HDP',
      'subDesc': 'Pelapis rokiran per dengan busa',
      'icon': Icons.bed_outlined,
    },
    {
      'name': 'Material Springbed',
      'desc': 'Quilting',
      'subDesc': 'Kesan timbul dan tampilan yang elegan',
      'icon': Icons.texture,
    },
    {
      'name': 'Material Springbed',
      'desc': 'Kain Polos Springbed',
      'subDesc': 'Lapisan luar pembungkus bagian atas kasur',
      'icon': Icons.layers_outlined,
    },
    {
      'name': 'Material Springbed',
      'desc': 'Percale',
      'subDesc': 'Memberikan daya topang pada tubuh saat tidur',
      'icon': Icons.nature_people_outlined,
    },
    {
      'name': 'Material Springbed',
      'desc': 'Pita List',
      'subDesc': 'Penutup pinggiran kasur',
      'icon': Icons.border_all_outlined,
    },

    {'header': 'Material Sofa'},
    {
      'name': 'Material Sofa',
      'desc': 'Kain Polos Sofa',
      'subDesc': 'Bahan pelapis sofa yang elegan',
      'icon': Icons.weekend_outlined,
    },

    {'header': 'Material Springbed & Sofa'},
    {
      'name': 'Material Springbed & Sofa',
      'desc': 'Aksesoris',
      'subDesc': 'Komponen pelengkap menambah nilai estetika',
      'icon': Icons.extension_outlined,
    },
    {
      'name': 'Material Springbed & Sofa',
      'desc': 'Bahan Kimia',
      'subDesc': 'Menjaga agar tahan dalam jangka panjang',
      'icon': Icons.science_outlined,
    },
    {
      'name': 'Material Springbed & Sofa',
      'desc': 'Busa',
      'subDesc': 'Menjaga bentuk dan kenyamanan produk',
      'icon': Icons.bubble_chart_outlined,
    },
    {
      'name': 'Material Springbed & Sofa',
      'desc': 'Kawat',
      'subDesc': 'Penyambung dan penguat struktur',
      'icon': Icons.cable_outlined,
    },
    {
      'name': 'Material Springbed & Sofa',
      'desc': 'Non Woven',
      'subDesc': 'Lapisan pelindung antara busa dan kain',
      'icon': Icons.format_paint_outlined,
    },
    {
      'name': 'Material Springbed & Sofa',
      'desc': 'Plastik',
      'subDesc': 'Lapisan pelindung antara busa dan kain',
      'icon': Icons.ac_unit_outlined,
    },
    {
      'name': 'Material Springbed & Sofa',
      'desc': 'Stapless',
      'subDesc': 'Komponen pelindung antara busa dan kain',
      'icon': Icons.bolt_outlined,
    },

    {'header': 'Mesin & Sparepart'},
    {
      'name': 'Mesin & Sparepart',
      'desc': 'Other',
      'subDesc': 'Alat dan komponen pelengkap',
      'icon': Icons.settings_applications_outlined,
    },

    {'header': 'Furniture'},
    {
      'name': 'Furniture',
      'desc': 'Kasur',
      'subDesc': 'Nyenyak tidur dengan material unggulan',
      'icon': Icons.bed_outlined,
    },
    {
      'name': 'Furniture',
      'desc': 'Kitchen',
      'subDesc': 'Furniture dapur yang elegan dan estetik',
      'icon': Icons.kitchen_outlined,
    },
    {
      'name': 'Furniture',
      'desc': 'Lemari',
      'subDesc': 'Kombinasi kekuatan struktur dan estetika',
      'icon': Icons.all_inbox_outlined,
    },
    {
      'name': 'Furniture',
      'desc': 'Kursi',
      'subDesc': 'Tempat duduk yang nyaman dan kokoh',
      'icon': Icons.chair_outlined,
    },
    {
      'name': 'Furniture',
      'desc': 'Meja',
      'subDesc': 'Elemen penting dari interior',
      'icon': Icons.table_chart_outlined,
    },
    {
      'name': 'Furniture',
      'desc': 'Rak',
      'subDesc': 'Tempat menyimpan barang',
      'icon': Icons.radar_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Tentukan tinggi modal (misalnya 90% dari tinggi layar)
    final double screenHeight = MediaQuery.of(context).size.height;
    final double modalHeight = screenHeight * 0.9;

    return Container(
      height: modalHeight,
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle dan Judul Modal
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text(
              'Semua Produk',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),

          // Daftar Kategori
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 0),
              itemCount: _allCategories.length,
              itemBuilder: (context, index) {
                final category = _allCategories[index];

                if (category.containsKey('header')) {
                  // Header Kategori (misalnya 'Material Springbed')
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 16,
                      bottom: 8,
                    ),
                    child: Text(
                      category['header'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  );
                } else {
                  // Item Sub-Kategori (misalnya 'HDP', 'Quilting')
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(
                            category['icon'] as IconData,
                            color: Colors.black54,
                          ),
                        ),
                        title: Text(
                          category['desc'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          category['subDesc'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  category['targetPage'] as Widget,
                            ),
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(height: 1),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
