import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../database/wishlist_service.dart';
import '../models/wishlist_model.dart';
import 'add_wishlist_screen.dart';
import 'detail_wishlist_screen.dart';

class WishlistScreen extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;

  const WishlistScreen({super.key, required this.refreshNotifier});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistItem> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget.refreshNotifier.addListener(_loadWishlistItems);
    _loadWishlistItems();
  }

  @override
  void dispose() {
    widget.refreshNotifier.removeListener(_loadWishlistItems);
    super.dispose();
  }

  Future<void> _loadWishlistItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await WishlistService().getAllWishlistItems();
      if (mounted) {
        setState(() {
          _wishlistItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Wishlist',
          style: GoogleFonts.manrope(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWishlistItems,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionTitle('Prioritas'),
                  const SizedBox(height: 16),
                  ..._buildPriorityItems(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Lainnya'),
                  const SizedBox(height: 16),
                  ..._buildOtherItems(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: "wishlist_add_btn",
        onPressed: () => _navigateToAddWishlist(),
        backgroundColor: const Color(0xFF2C2C54),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _navigateToAddWishlist() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWishlistScreen()),
    );

    if (result == true) {
      _loadWishlistItems();
      widget.refreshNotifier.value++;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  List<Widget> _buildPriorityItems() {
    final priorityItems = _wishlistItems
        .where((item) => item.isPriority)
        .toList();

    if (priorityItems.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Belum ada item prioritas',
            style: GoogleFonts.manrope(color: Colors.grey[600]),
          ),
        ),
      ];
    }

    return priorityItems.map((item) => _buildPriorityCard(item)).toList();
  }

  List<Widget> _buildOtherItems() {
    final otherItems = _wishlistItems
        .where((item) => !item.isPriority)
        .toList();

    if (otherItems.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Belum ada item lainnya',
            style: GoogleFonts.manrope(color: Colors.grey[600]),
          ),
        ),
      ];
    }

    return otherItems.map((item) => _buildOtherCard(item)).toList();
  }

  Widget _buildPriorityCard(WishlistItem item) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: () => _navigateToDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () => _showItemOptions(item),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(item.targetAmount),
              style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: item.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2C2C54),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(item.progressPercentage * 100).toStringAsFixed(1)}% tercapai',
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherCard(WishlistItem item) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: () => _navigateToDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(item.targetAmount),
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () => _showItemOptions(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(WishlistItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailWishlistScreen(wishlistItem: item),
      ),
    );

    // Refresh the list if changes were made
    if (result == true) {
      _loadWishlistItems();
      widget.refreshNotifier.value++;
    }
  }

  void _showItemOptions(WishlistItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF2C2C54)),
                title: Text(
                  'Edit Item',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditWishlistDialog(item);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Hapus Item',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteWishlistItem(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddWishlistDialog() {
    _navigateToAddWishlist();
  }

  void _showEditWishlistDialog(WishlistItem item) {
    final titleController = TextEditingController(text: item.title);
    final targetAmountController = TextEditingController(
      text: item.targetAmount.toString(),
    );
    final descriptionController = TextEditingController(text: item.description);
    bool isPriority = item.isPriority;

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
                    item,
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

  Future<void> _addWishlistItem(
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

    final newItem = WishlistItem(
      userId: 1,
      title: title,
      targetAmount: amount,
      description: description,
      isPriority: isPriority,
      createdAt: DateTime.now(),
    );

    final result = await WishlistService().addWishlistItem(newItem);

    if (mounted) {
      Navigator.pop(context);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item berhasil ditambahkan')),
        );
        _loadWishlistItems();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  Future<void> _updateWishlistItem(
    WishlistItem item,
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

    final updatedItem = WishlistItem(
      id: item.id,
      userId: item.userId,
      title: title,
      targetAmount: amount,
      currentAmount: item.currentAmount,
      description: description,
      isPriority: isPriority,
      createdAt: item.createdAt,
    );

    final result = await WishlistService().updateWishlistItem(updatedItem);

    if (mounted) {
      Navigator.pop(context);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item berhasil diupdate')));
        _loadWishlistItems();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  Future<void> _deleteWishlistItem(WishlistItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hapus Item',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${item.title}"?',
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

    if (confirmed == true && item.id != null) {
      final result = await WishlistService().deleteWishlistItem(item.id!);

      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item berhasil dihapus')),
          );
          _loadWishlistItems();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result['message'])));
        }
      }
    }
  }
}
