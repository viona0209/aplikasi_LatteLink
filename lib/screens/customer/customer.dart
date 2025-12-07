import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../widgets/sidebar_menu.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final Color primaryColor = const Color(0xFF6E200D);
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> customers = [];
  bool isLoading = false;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  void _showSuccessToast(String message) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF6E200D),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 2), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Future<void> fetchCustomers() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('customers')
          .select()
          .order('customers_id', ascending: true);

      setState(() {
        customers = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint("FETCH CUSTOMERS ERROR: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteCustomer(int id, String name) async {
    try {
      await supabase.from('customers').delete().eq('customers_id', id);
      await fetchCustomers();
      _showSuccessToast('Customer "$name" berhasil dihapus');
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
      _showSuccessToast('Gagal menghapus customer');
    }
  }

  Future<void> _confirmAndDelete(String name, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Konfirmasi Hapus",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Hapus customer "$name"?\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Hapus",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteCustomer(id, name);
    }
  }

  void _openCustomSidebar() {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: size.width < 600 ? size.width * 0.8 : 350,
              height: size.height * 0.9,
              margin: const EdgeInsets.only(top: 40, bottom: 60),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Material(
                  color: Colors.white,
                  child: SidebarMenu(selected: "customer"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => _CustomerDialog(
        title: "Tambah Customer",
        onSuccess: () {
          fetchCustomers();
          _showSuccessToast("Customer berhasil ditambahkan");
        },
      ),
    );
  }

  void _showEditCustomerDialog(int index) {
    final customer = customers[index];
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => _CustomerDialog(
        title: "Edit Customer",
        customer: customer,
        onSuccess: () {
          fetchCustomers();
          _showSuccessToast("Customer berhasil diperbarui");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final bool isSmall = screenWidth < 360;
        final double paddingHorizontal = isSmall ? 16 : 28;
        final double headerFont = isSmall ? 18 : 24;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 25, left: 25),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: primaryColor,
                          size: isSmall ? 24 : 28,
                        ),
                        onPressed: _openCustomSidebar,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Customer",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: headerFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _showAddCustomerDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFAFACAC),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFFAFACAC)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (v) =>
                                  setState(() => searchQuery = v.toLowerCase()),
                              decoration: const InputDecoration(
                                hintText: "Cari customer...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFAFACAC),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : customers.isEmpty
                          ? const Center(
                              child: Text(
                                "Belum ada customer",
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: customers.length,
                              itemBuilder: (context, index) {
                                final customer = customers[index];
                                final name = customer["name"] ?? "Tanpa Nama";
                                final firstLetter = name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : "?";

                                if (searchQuery.isNotEmpty &&
                                    !name.toLowerCase().contains(searchQuery)) {
                                  return const SizedBox.shrink();
                                }
                                return Slidable(
                                  key: ValueKey(customer["customers_id"]),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    extentRatio: 0.3,
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) => _confirmAndDelete(
                                          name,
                                          customer["customers_id"],
                                        ),
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Hapus',
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    height: 115,
                                    margin: const EdgeInsets.only(bottom: 15),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: primaryColor,
                                          child: Text(
                                            firstLetter,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                customer["phone"] ?? "-",
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: primaryColor,
                                              ),
                                              onPressed: () =>
                                                  _showEditCustomerDialog(
                                                    index,
                                                  ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        CustomerDetailPage(
                                                          customerId:
                                                              customer["customers_id"]
                                                                  .toString(),
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  "Detail",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}

class _CustomerDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? customer;
  final VoidCallback? onSuccess;

  const _CustomerDialog({required this.title, this.customer, this.onSuccess});

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  String? nameError;
  String? phoneError;
  String? addressError;

  final Color primaryColor = const Color(0xFF6E200D);

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.customer?["name"] ?? "",
    );
    phoneController = TextEditingController(
      text: widget.customer?["phone"] ?? "",
    );
    addressController = TextEditingController(
      text: widget.customer?["address"] ?? "",
    );
  }

  bool _validate() {
    setState(() {
      nameError = nameController.text.trim().isEmpty
          ? "Nama wajib diisi"
          : nameController.text.trim().length < 3
          ? "Minimal 3 karakter"
          : null;

      final phone = phoneController.text.trim();
      phoneError = phone.isEmpty
          ? "No. telepon wajib diisi"
          : !RegExp(r'^[0-9]+$').hasMatch(phone)
          ? "Hanya boleh angka"
          : phone.length < 10
          ? "Minimal 10 digit"
          : null;

      addressError = addressController.text.trim().isEmpty
          ? "Alamat wajib diisi"
          : null;
    });

    return nameError == null && phoneError == null && addressError == null;
  }

  Future<void> _save() async {
    if (!_validate()) return;

    final supabase = Supabase.instance.client;

    try {
      if (widget.customer == null) {
        await supabase.from('customers').insert({
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "address": addressController.text.trim(),
        });
      } else {
        await supabase
            .from('customers')
            .update({
              "name": nameController.text.trim(),
              "phone": phoneController.text.trim(),
              "address": addressController.text.trim(),
            })
            .eq("customers_id", widget.customer!["customers_id"]);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess?.call();
      }
    } catch (e) {
      debugPrint("SAVE CUSTOMER ERROR: $e");
    }
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  Widget _field(TextEditingController controller, {String? error}) => TextField(
    controller: controller,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: error != null ? Colors.red : const Color(0xFFAFACAC),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorText: error,
      errorStyle: const TextStyle(color: Colors.red),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 346,
          constraints: const BoxConstraints(maxHeight: 580),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor, width: 3),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _label("Nama"),
                _field(nameController, error: nameError),
                const SizedBox(height: 16),
                _label("No. Telepon"),
                _field(phoneController, error: phoneError),
                const SizedBox(height: 16),
                _label("Alamat"),
                _field(addressController, error: addressError),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD7A797),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
