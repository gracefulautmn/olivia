import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/app_colors.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/item/presentation/bloc/report_item/report_item_bloc.dart';
import 'package:olivia/common_widgets/custom_button.dart'; // Asumsi ada widget ini
import 'package:olivia/common_widgets/loading_indicator.dart'; // Asumsi ada widget ini

class ReportItemPage extends StatelessWidget {
  const ReportItemPage({super.key});

  static const String routeName = '/report-item';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReportItemBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lapor Barang'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<ReportItemBloc, ReportItemState>(
          listener: (context, state) {
            if (state.status == ReportItemStatus.failure &&
                state.failure != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.failure!.message),
                    backgroundColor: Colors.red,
                  ),
                );
            }
            if (state.status == ReportItemStatus.success &&
                state.reportedItem != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Laporan "${state.reportedItem!.itemName}" berhasil dibuat!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              context.pop(); // Kembali ke halaman sebelumnya
            }
          },
          builder: (context, state) {
            if (state.status == ReportItemStatus.loadingFormData) {
              return const Center(child: LoadingIndicator());
            }
            return _ReportItemForm();
          },
        ),
      ),
    );
  }
}

class _ReportItemForm extends StatefulWidget {
  @override
  __ReportItemFormState createState() => __ReportItemFormState();
}

class __ReportItemFormState extends State<_ReportItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Isi controller jika ada data di state (misal saat edit, tapi ini untuk create)
    final initialState = context.read<ReportItemBloc>().state;
    _itemNameController.text = initialState.itemName;
    _descriptionController.text = initialState.description;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800, // Batasi ukuran gambar
        imageQuality: 85, // Kompresi gambar
      );
      if (pickedFile != null) {
        context.read<ReportItemBloc>().add(
          ReportItemImagePicked(File(pickedFile.path)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState =
        context.watch<AuthBloc>().state; // Untuk mendapatkan currentUserId
    final reportBloc = context.watch<ReportItemBloc>();
    final state = reportBloc.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Jenis Laporan (Kehilangan/Penemuan)
            SegmentedButton<ReportType>(
              segments: const <ButtonSegment<ReportType>>[
                ButtonSegment<ReportType>(
                  value: ReportType.kehilangan,
                  label: Text('Kehilangan'),
                  icon: Icon(Icons.search_off),
                ),
                ButtonSegment<ReportType>(
                  value: ReportType.penemuan,
                  label: Text('Penemuan'),
                  icon: Icon(Icons.visibility),
                ),
              ],
              selected: <ReportType>{state.reportType},
              onSelectionChanged: (Set<ReportType> newSelection) {
                reportBloc.add(ReportItemTypeChanged(newSelection.first));
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor:
                    state.reportType == ReportType.kehilangan
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                selectedForegroundColor:
                    state.reportType == ReportType.kehilangan
                        ? Colors.orange.shade800
                        : Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 20),

            // Nama Barang
            TextFormField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Barang*',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_important_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama barang tidak boleh kosong';
                }
                return null;
              },
              onChanged:
                  (value) => reportBloc.add(ReportItemNameChanged(value)),
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Tambahan (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onChanged:
                  (value) =>
                      reportBloc.add(ReportItemDescriptionChanged(value)),
            ),
            const SizedBox(height: 16),

            // Kategori
            DropdownButtonFormField<CategoryEntity>(
              value: state.selectedCategory,
              decoration: InputDecoration(
                labelText:
                    'Kategori Barang${state.reportType == ReportType.penemuan ? "*" : ""}', // Wajib jika penemuan
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              hint: const Text('Pilih Kategori'),
              isExpanded: true,
              items:
                  state.categories.map((CategoryEntity category) {
                    return DropdownMenuItem<CategoryEntity>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
              onChanged: (CategoryEntity? newValue) {
                reportBloc.add(ReportItemCategoryChanged(newValue));
              },
              validator: (value) {
                if (state.reportType == ReportType.penemuan && value == null) {
                  return 'Kategori wajib diisi untuk barang temuan';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Lokasi
            DropdownButtonFormField<LocationEntity>(
              value: state.selectedLocation,
              decoration: InputDecoration(
                labelText:
                    'Lokasi ${state.reportType == ReportType.penemuan ? "Penemuan*" : "Terakhir Dilihat*"}',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              hint: const Text('Pilih Lokasi'),
              isExpanded: true,
              items:
                  state.locations.map((LocationEntity location) {
                    return DropdownMenuItem<LocationEntity>(
                      value: location,
                      child: Text(location.name),
                    );
                  }).toList(),
              onChanged: (LocationEntity? newValue) {
                reportBloc.add(ReportItemLocationChanged(newValue));
              },
              validator: (value) {
                if (value == null) {
                  return 'Lokasi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Upload Gambar
            Text(
              'Foto Barang (Opsional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    state.imageFile != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            state.imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                        : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              Text('Ketuk untuk menambah foto'),
                            ],
                          ),
                        ),
              ),
            ),
            if (state.imageFile != null)
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Hapus Foto',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed:
                    () => reportBloc.add(const ReportItemImagePicked(null)),
              ),
            const SizedBox(height: 24),

            // Tombol Submit
            if (state.status == ReportItemStatus.loading)
              const Center(child: LoadingIndicator())
            else
              CustomButton(
                text: 'Kirim Laporan',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (authState.status == AuthStatus.authenticated &&
                        authState.user != null) {
                      reportBloc.add(
                        ReportItemSubmitted(currentUserId: authState.user!.id),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Anda harus login untuk membuat laporan.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                backgroundColor: AppColors.primaryColor,
                textColor: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
