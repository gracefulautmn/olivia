import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olivia/core/di/service_locator.dart';
import 'package:olivia/core/utils/enums.dart';
import 'package:olivia/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olivia/features/home/domain/entities/category.dart';
import 'package:olivia/features/home/domain/entities/location.dart';
import 'package:olivia/features/item/presentation/bloc/report_item/report_item_bloc.dart';
import 'package:olivia/common_widgets/custom_button.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';
import 'package:olivia/navigation/main_navigation_scaffold.dart';

class ReportItemPage extends StatelessWidget {
  const ReportItemPage({super.key});

  static const String routeName = '/report-item';

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final bool isSecurity = authState.user?.role == UserRole.keamanan;
    // Tentukan jenis laporan dan judul halaman berdasarkan peran
    final ReportType reportType =
        isSecurity ? ReportType.penemuan : ReportType.kehilangan;
    final String pageTitle =
        isSecurity ? 'Lapor Barang Temuan' : 'Lapor Barang Hilang';

    return BlocProvider(
      create: (context) =>
          sl<ReportItemBloc>()..add(ReportItemTypeChanged(reportType)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go(MainNavigationScaffold.routeName),
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
              context.go(MainNavigationScaffold.routeName);
            }
          },
          builder: (context, state) {
            if (state.status == ReportItemStatus.loadingFormData) {
              return const Center(child: LoadingIndicator());
            }
            // Kirim reportType ke form
            return _ReportItemForm(reportType: reportType);
          },
        ),
      ),
    );
  }
}

class _ReportItemForm extends StatefulWidget {
  final ReportType reportType;
  const _ReportItemForm({required this.reportType});

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
        maxWidth: 800,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        context.read<ReportItemBloc>().add(
              ReportItemImagePicked(File(pickedFile.path)),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
      }
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
    final authState = context.watch<AuthBloc>().state;
    final reportBloc = context.watch<ReportItemBloc>();
    final state = reportBloc.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // SegmentedButton sudah dihapus karena logika peran ada di atas

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
              onChanged: (value) =>
                  reportBloc.add(ReportItemNameChanged(value)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Tambahan (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onChanged: (value) =>
                  reportBloc.add(ReportItemDescriptionChanged(value)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CategoryEntity>(
              value: state.selectedCategory,
              decoration: InputDecoration(
                labelText:
                    'Kategori Barang${widget.reportType == ReportType.penemuan ? "*" : ""}',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              hint: const Text('Pilih Kategori'),
              items: state.categories.map((CategoryEntity category) {
                return DropdownMenuItem<CategoryEntity>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (CategoryEntity? newValue) {
                reportBloc.add(ReportItemCategoryChanged(newValue));
              },
              validator: (value) {
                if (widget.reportType == ReportType.penemuan &&
                    value == null) {
                  return 'Kategori wajib diisi untuk barang temuan';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LocationEntity>(
              value: state.selectedLocation,
              decoration: InputDecoration(
                labelText:
                    'Lokasi ${widget.reportType == ReportType.penemuan ? "Penemuan*" : "Terakhir Dilihat*"}',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              hint: const Text('Pilih Lokasi'),
              items: state.locations.map((LocationEntity location) {
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
            
            // PERBAIKAN: Label upload gambar sekarang dinamis
            Text(
              'Foto Barang${widget.reportType == ReportType.penemuan ? "*" : " (Opsional)"}',
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
                child: state.imageFile != null
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
                            Icon(Icons.add_a_photo_outlined,
                                size: 40, color: Colors.grey),
                            Text('Ketuk untuk menambah foto'),
                          ],
                        ),
                      ),
              ),
            ),
            if (state.imageFile != null)
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label:
                    const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                onPressed: () =>
                    reportBloc.add(const ReportItemImagePicked(null)),
              ),
            const SizedBox(height: 24),
            
            // Tombol Submit
            CustomButton(
              text: 'Kirim Laporan',
              isLoading: state.status == ReportItemStatus.loading,
              onPressed: () {
                // PERBAIKAN: Tambahkan validasi gambar untuk laporan penemuan
                final isFormValid = _formKey.currentState?.validate() ?? false;
                if (!isFormValid) {
                  return;
                }

                if (widget.reportType == ReportType.penemuan && state.imageFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Foto barang wajib diisi untuk laporan penemuan.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (authState.user != null) {
                  reportBloc.add(ReportItemSubmitted(currentUserId: authState.user!.id));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
