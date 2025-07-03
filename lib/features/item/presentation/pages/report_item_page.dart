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
import 'package:olivia/features/home/presentation/pages/home_page.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/presentation/bloc/report_item/report_item_bloc.dart';
import 'package:olivia/common_widgets/custom_button.dart';
import 'package:olivia/common_widgets/loading_indicator.dart';

class ReportItemPage extends StatelessWidget {
  final ItemEntity? itemToEdit;
  const ReportItemPage({super.key, this.itemToEdit});

  static const String routeName = '/report-item';

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = itemToEdit != null;

    final ReportType reportType = isEditMode
        ? itemToEdit!.reportType
        : (context.read<AuthBloc>().state.user?.role == UserRole.keamanan
            ? ReportType.penemuan
            : ReportType.kehilangan);
        
    final String pageTitle = isEditMode
        ? 'Edit Laporan'
        : (reportType == ReportType.penemuan ? 'Lapor Barang Temuan' : 'Lapor Barang Hilang');

    return BlocProvider(
      create: (context) {
        final bloc = sl<ReportItemBloc>();
        if (isEditMode) {
          bloc.add(InitializeForEdit(itemToEdit!));
        } else {
          bloc.add(ReportItemTypeChanged(reportType));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(pageTitle, style: const TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
          // --- PERBAIKAN: Tombol close sekarang selalu kembali ke Beranda ---
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.goNamed(HomePage.routeName),
          ),
        ),
        body: BlocConsumer<ReportItemBloc, ReportItemState>(
          listener: (context, state) {
            if (state.status == ReportItemStatus.failure && state.failure != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.failure!.message),
                    backgroundColor: Colors.red,
                  ),
                );
            }
            if (state.status == ReportItemStatus.success) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(isEditMode ? 'Laporan berhasil diperbarui!' : 'Laporan berhasil dibuat!'),
                    backgroundColor: Colors.green,
                  ),
                );
              // --- PERBAIKAN: Kembali ke Beranda setelah sukses ---
              context.goNamed(HomePage.routeName);
            }
          },
          builder: (context, state) {
            if (state.status == ReportItemStatus.loadingFormData) {
              return const Center(child: LoadingIndicator());
            }
            return _ReportItemForm(
              reportType: reportType,
              isEditMode: isEditMode,
              initialImageUrl: isEditMode ? itemToEdit!.imageUrl : null,
              itemToEditId: isEditMode ? itemToEdit!.id : null,
            );
          },
        ),
      ),
    );
  }
}

class _ReportItemForm extends StatefulWidget {
  final ReportType reportType;
  final bool isEditMode;
  final String? initialImageUrl;
  final String? itemToEditId;

  const _ReportItemForm({
    required this.reportType,
    required this.isEditMode,
    this.initialImageUrl,
    this.itemToEditId,
  });

  @override
  __ReportItemFormState createState() => __ReportItemFormState();
}

class __ReportItemFormState extends State<_ReportItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

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
    
    return BlocListener<ReportItemBloc, ReportItemState>(
      listener: (context, state) {
        if (_itemNameController.text != state.itemName) {
          _itemNameController.text = state.itemName;
        }
        if (_descriptionController.text != state.description) {
          _descriptionController.text = state.description;
        }
      },
      child: Builder(
        builder: (context) {
          final state = context.watch<ReportItemBloc>().state;
          
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Color(0xFFE3F2FD),
                  Color(0xFF81D4FA),
                  Color(0xFF4FC3F7),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_important_outline),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Nama barang tidak boleh kosong' : null,
                      onChanged: (value) => context.read<ReportItemBloc>().add(ReportItemNameChanged(value)),
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
                      onChanged: (value) => context.read<ReportItemBloc>().add(ReportItemDescriptionChanged(value)),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CategoryEntity>(
                      value: state.categories.any((c) => c.id == state.selectedCategory?.id) ? state.selectedCategory : null,
                      decoration: InputDecoration(
                        labelText: 'Kategori Barang${widget.reportType == ReportType.penemuan ? "*" : ""}',
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
                      onChanged: (CategoryEntity? newValue) => context.read<ReportItemBloc>().add(ReportItemCategoryChanged(newValue)),
                      validator: (value) {
                        if (widget.reportType == ReportType.penemuan && value == null) {
                          return 'Kategori wajib diisi untuk barang temuan';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LocationEntity>(
                      value: state.locations.any((l) => l.id == state.selectedLocation?.id) ? state.selectedLocation : null,
                      decoration: InputDecoration(
                        labelText: 'Lokasi ${widget.reportType == ReportType.penemuan ? "Penemuan*" : "Terakhir Dilihat*"}',
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
                      onChanged: (LocationEntity? newValue) => context.read<ReportItemBloc>().add(ReportItemLocationChanged(newValue)),
                      validator: (value) => value == null ? 'Lokasi wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Foto Barang${widget.reportType == ReportType.penemuan ? "*" : " (Opsional)"}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: state.imageFile != null
                              ? Image.file(state.imageFile!, fit: BoxFit.cover)
                              : (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty
                                  ? Image.network(widget.initialImageUrl!, fit: BoxFit.cover)
                                  : const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                                          Text('Ketuk untuk menambah foto'),
                                        ],
                                      ),
                                    )),
                        ),
                      ),
                    ),
                    if (state.imageFile != null || (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty))
                      TextButton.icon(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                        onPressed: () => context.read<ReportItemBloc>().add(const ReportItemImagePicked(null)),
                      ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: widget.isEditMode ? 'Simpan Perubahan' : 'Kirim Laporan',
                      isLoading: state.status == ReportItemStatus.loading,
                      onPressed: () {
                        final isFormValid = _formKey.currentState?.validate() ?? false;
                        if (!isFormValid) return;
                        
                        if (widget.reportType == ReportType.penemuan && state.imageFile == null && (widget.initialImageUrl == null || widget.initialImageUrl!.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Foto barang wajib diisi untuk laporan penemuan.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (authState.user != null) {
                          if (widget.isEditMode) {
                            context.read<ReportItemBloc>().add(UpdateItemSubmitted(itemId: widget.itemToEditId!));
                          } else {
                            context.read<ReportItemBloc>().add(ReportItemSubmitted(currentUserId: authState.user!.id));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
