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
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: _buildHeaderWithOverlay(context),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          CategoriesListWidget(categories: state.categories),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 20.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200)),
                            child: const Text(
                              'Jaga barang bawaan Anda dengan baik. Kehilangan dapat merepotkan!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.blueGrey),
                            ),
                          ),
                          LocationsListWidget(locations: state.locations),
                          const SizedBox(height: 20),
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
                          const SizedBox(
                              height: 80), // Space untuk floating chat button
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(
                child: Text('Selamat datang! Sedang memuat data...'));
          },
        ),
      ),
    );
  }

  Widget _buildHeaderWithOverlay(BuildContext context) {
    const double headerHeight = 230.0; // Sedikit ditambah untuk ruang gradasi
    const double borderRadiusValue = 25.0; // Nilai radius untuk lengkungan

    return Stack(
      children: <Widget>[
        // 1. Gambar Iklan sebagai background
        Container(
          height: headerHeight,
          width: double.infinity,
          decoration: const BoxDecoration(
            // Lengkungan hanya di bagian bawah
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(borderRadiusValue)),
            image: DecorationImage(
              image: AssetImage('assets/baranghilang.png'), // Pastikan path ini benar
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 2. Overlay Gradasi untuk transisi ke putih di bagian bawah
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: headerHeight * 0.5, // Tinggi gradasi (misal, 50% dari tinggi header)
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(borderRadiusValue)), // Cocokkan radius
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     Colors.transparent, // Mulai transparan dari atas gradasi
              //     Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              //     Theme.of(context).scaffoldBackgroundColor, // Berakhir dengan warna scaffold
              //   ],
              //   stops: const [0.0, 0.6, 1.0], // Kontrol penyebaran gradasi
              // ),
            ),
          ),
        ),

        // 3. Konten yang di-overlay (Search bar dan Profile Icon)
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed(SearchResultsPage.routeName);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.95), // Lebih baik menggunakan warna tema
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Theme.of(context).hintColor, size: 20),
                        const SizedBox(width: 8),
                        Text('Cari barang...',
                            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Theme.of(context).cardColor.withOpacity(0.95),
                shape: const CircleBorder(),
                elevation: 2.0,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    context.pushNamed(ProfilePage.routeName);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).primaryColor, // Menggunakan warna primer tema
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
