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
          image: NetworkImage('https://chatgpt.com/s/m_684051d7afc88191b9229518383072a9'),
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