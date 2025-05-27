import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/home/presentation/bloc/home_bloc.dart';
import 'package:olivia/features/home/presentation/widgets/categories_list_widget.dart';
import 'package:olivia/features/home/presentation/widgets/items_carousel_widget.dart';
import 'package:olivia/features/home/presentation/widgets/locations_list_widget.dart';
import 'package:olivia/features/profile/presentation/pages/profile_page.dart';
import 'package:olivia/features/item/presentation/pages/search_results_page.dart'; // Untuk pencarian

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = '/home'; // Sesuaikan dengan ShellRoute

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeBloc>()..add(FetchHomeData()),
      child: Scaffold(
        appBar: AppBar(
          title: _buildSearchField(context),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                context.push(ProfilePage.routeName); // Navigasi ke Profile
              },
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is HomeError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                   context.read<HomeBloc>().add(FetchHomeData());
                },
                child: ListView(
                  padding: const EdgeInsets.all(0), // Hapus padding default ListView
                  children: [
                    // 1. Iklan (Placeholder)
                    Container(
                      height: 150,
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: NetworkImage('https://via.placeholder.com/600x250/005AAB/FFFFFF?Text=Promosi+Kampus'), // Ganti dengan URL gambar iklan
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(child: Text('', style: TextStyle(color: Colors.white, fontSize: 20))),
                    ),
              
                    // 2. List Kategori
                    CategoriesListWidget(categories: state.categories),
              
                    // 3. Kotak Kata-kata
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200)
                      ),
                      child: const Text(
                        'Jaga barang bawaan Anda dengan baik. Kehilangan dapat merepotkan!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                      ),
                    ),
              
                    // 4. List Lokasi
                    LocationsListWidget(locations: state.locations),
                    const SizedBox(height: 20),
              
                    // 5. Temuan Barang Hilang (Found Items)
                    if (state.recentFoundItems.isNotEmpty)
                      ItemsCarouselWidget(
                        title: 'Temuan Barang Terbaru',
                        items: state.recentFoundItems,
                        onSeeAll: () {
                          context.pushNamed(
                            SearchResultsPage.routeName,
                            queryParameters: {'reportType': 'penemuan'},
                          );
                        },
                      ),
              
                    // 6. Laporan Barang Hilang (Lost Items)
                    if (state.recentLostItems.isNotEmpty)
                      ItemsCarouselWidget(
                        title: 'Laporan Kehilangan Terbaru',
                        items: state.recentLostItems,
                        onSeeAll: () {
                           context.pushNamed(
                            SearchResultsPage.routeName,
                            queryParameters: {'reportType': 'kehilangan'},
                          );
                        },
                      ),
                    const SizedBox(height: 80), // Space untuk floating chat button
                  ],
                ),
              );
            }
            return const Center(child: Text('Selamat datang! Sedang memuat data...'));
          },
        ),
        // Floating chat button akan ditambahkan di MainNavigationScaffold atau sebagai widget global
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman pencarian atau tampilkan overlay pencarian
        context.pushNamed(SearchResultsPage.routeName);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.white70, size: 20),
            SizedBox(width: 8),
            Text('Cari barang...', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}