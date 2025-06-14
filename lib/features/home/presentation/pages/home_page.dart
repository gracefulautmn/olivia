import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:olivia/features/feedback/presentation/pages/feedback_page.dart';
import 'package:olivia/features/home/presentation/bloc/home_bloc.dart';
import 'package:olivia/features/home/presentation/widgets/categories_list_widget.dart';
import 'package:olivia/features/home/presentation/widgets/items_carousel_widget.dart';
import 'package:olivia/features/home/presentation/widgets/locations_list_widget.dart';
import 'package:olivia/features/profile/presentation/pages/profile_page.dart';
import 'package:olivia/features/item/presentation/pages/search_results_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeBloc>()..add(FetchHomeData()),
      // PERBAIKAN: Bungkus dengan Scaffold di sini untuk menempatkan FAB
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
                              'Jaga barang bawaan Anda dengan baik !',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.blueGrey),
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
                          // Laporan Kehilangan tidak lagi ditampilkan sesuai revisi sebelumnya
                          // if (state.recentLostItems.isNotEmpty) ...
                          
                          const SizedBox(height: 80), // Space untuk FAB
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
        // PERBAIKAN: FAB sekarang menjadi bagian dari Scaffold HomePage
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showSupportOptions(context),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.support_agent_outlined, color: Colors.white),
        ),
        // PENTING: Gunakan FloatingActionButtonLocation yang sesuai jika tidak ada BottomAppBar
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  // --- Fungsi helper dipindahkan ke dalam HomePage ---

  void _showSupportOptions(BuildContext context) {
    const String securityUserId = 'af7321dd-7ce2-4112-999e-0b88edad8d0d';
    const String securityUserName = 'Keamanan';

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Lapor Bug / Beri Masukan Aplikasi'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.pushNamed(FeedbackPage.routeName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('Hubungi Keamanan'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.pushNamed(
                    ChatDetailPage.routeName,
                    pathParameters: {'chatRoomId': 'new'},
                    queryParameters: {
                      'recipientId': securityUserId,
                      'recipientName': securityUserName,
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderWithOverlay(BuildContext context) {
    const double headerHeight = 230.0;
    const double borderRadiusValue = 25.0;

    return Stack(
      children: <Widget>[
        Container(
          height: headerHeight,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(borderRadiusValue)),
            image: DecorationImage(
              image: AssetImage('assets/baranghilang.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(borderRadiusValue)),
              
            ),
          ),
        ),
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
                      color: Theme.of(context).cardColor.withOpacity(0.95),
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
                            style: TextStyle(
                                color: Theme.of(context).hintColor, fontSize: 16)),
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
                      color: Theme.of(context).primaryColor,
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
