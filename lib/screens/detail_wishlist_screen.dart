import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/wishlist_model.dart';
import '../database/wishlist_service.dart';
import 'add_wishlist_screen.dart';

class DetailWishlistScreen extends StatefulWidget {
  final WishlistItem wishlistItem;

  const DetailWishlistScreen({super.key, required this.wishlistItem});

  @override
  State<DetailWishlistScreen> createState() => _DetailWishlistScreenState();
}

class _DetailWishlistScreenState extends State<DetailWishlistScreen> {
  late WishlistItem _currentItem;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.wishlistItem;
  }

  Future<void> _navigateToEdit() async {
    // For now, we'll use a simple edit dialog
    // You can replace this with navigation to edit screen if needed
    await _showEditDialog();
  }

  Future<void> _showEditDialog() async {
    final titleController = TextEditingController(text: _currentItem.title);
    final targetAmountController = TextEditingController(
      text: _currentItem.targetAmount.toString(),
    );
    final descriptionController = TextEditingController(
      text: _currentItem.description,
    );
    bool isPriority = _currentItem.isPriority;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Wishlist',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Harga',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Prioritas'),
                    value: isPriority,
                    onChanged: (value) {
                      setState(() {
                        isPriority = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => _updateWishlistItem(
                    titleController.text,
                    targetAmountController.text,
                    descriptionController.text,
                    isPriority,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C54),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateWishlistItem(
    String title,
    String targetAmount,
    String description,
    bool isPriority,
  ) async {
    if (title.isEmpty || targetAmount.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama item dan target harga wajib diisi'),
          ),
        );
      }
      return;
    }

    final amount = double.tryParse(targetAmount) ?? 0.0;
    if (amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target harga harus lebih dari 0')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedItem = WishlistItem(
      id: _currentItem.id,
      userId: _currentItem.userId,
      title: title,
      targetAmount: amount,
      currentAmount: _currentItem.currentAmount,
      description: description,
      isPriority: isPriority,
      createdAt: _currentItem.createdAt,
    );

    final result = await WishlistService().updateWishlistItem(updatedItem);

    if (mounted) {
      Navigator.pop(context);
      if (result['status'] == 'success') {
        setState(() {
          _currentItem = updatedItem;
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item berhasil diupdate')));
        Navigator.pop(context, true); // Return true to indicate changes
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  Future<void> _deleteWishlistItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hapus Item',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${_currentItem.title}"?',
            style: GoogleFonts.manrope(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && _currentItem.id != null) {
      setState(() {
        _isLoading = true;
      });

      final result = await WishlistService().deleteWishlistItem(
        _currentItem.id!,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item berhasil dihapus')),
          );
          Navigator.pop(context, true); // Return true to indicate changes
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result['message'])));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Wishlist',
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Title
                    Center(
                      child: Text(
                        _currentItem.title,
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Priority indicator
                    if (_currentItem.isPriority)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            'Prioritas',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 60),

                    // Price section
                    _buildDetailSection(
                      'Harga',
                      formatter.format(_currentItem.targetAmount),
                    ),

                    const SizedBox(height: 24),

                    // Category section
                    _buildDetailSection(
                      'Kategori',
                      'Sekunder', // You can make this dynamic based on your data
                    ),

                    const SizedBox(height: 24),

                    // Description section
                    _buildDetailSection(
                      'Keterangan',
                      _currentItem.description.isNotEmpty
                          ? _currentItem.description
                          : 'Lorem ipsum dolor sit amet consequere',
                    ),

                    const SizedBox(height: 80),

                    // Action buttons - positions swapped
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _deleteWishlistItem,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Hapus Wishlist',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _navigateToEdit,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF2C2C54)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Edit Wishlist',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C54),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.manrope(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
