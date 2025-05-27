import 'package:flutter/material.dart';

class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          // Ganti dengan URL gambar iklan Anda atau aset lokal
          image: NetworkImage('https://via.placeholder.com/600x250/005AAB/FFFFFF?Text=Informasi+Penting+Kampus'),
          fit: BoxFit.cover,
        ),
      ),
      // child: const Center(
      //   child: Text(
      //     'Area Iklan/Promosi',
      //     style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      //   ),
      // ),
    );
  }
}