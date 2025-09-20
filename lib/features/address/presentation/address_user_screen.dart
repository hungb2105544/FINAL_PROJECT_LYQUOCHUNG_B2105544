import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/address/bloc/address_bloc.dart';
import 'package:ecommerce_app/features/address/bloc/address_event.dart';
import 'package:ecommerce_app/features/address/bloc/address_state.dart';
import 'package:ecommerce_app/features/address/data/model/user_address_model.dart';
import 'package:ecommerce_app/features/address/presentation/address_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class AddressUserScreen extends StatefulWidget {
  const AddressUserScreen({super.key});

  @override
  State<AddressUserScreen> createState() => _AddressUserScreenState();
}

class _AddressUserScreenState extends State<AddressUserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final client = SupabaseConfig.client;
      final String userId = client.auth.currentUser!.id;
      context.read<AddressBloc>().add(LoadAddress(userId: userId));
    });
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Thành công"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text("Lỗi"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Địa chỉ người dùng"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push<dynamic>(
            context,
            MaterialPageRoute(
              builder: (context) => AddressScreen(isAdd: true),
            ),
          );
        },
        child: const Icon(FontAwesomeIcons.add),
      ),
      body: BlocListener<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressOperationSuccess) {
            _showSuccessDialog(context, "Thao tác thành công");
          } else if (state is AddressError) {
            _showErrorDialog(context, state.message);
          }
        },
        child: BlocBuilder<AddressBloc, AddressState>(
          builder: (context, state) {
            if (state is AddressLoading) {
              return Center(
                  child: Lottie.asset('assets/lottie/loading_viemode.json',
                      width: 100, height: 100));
            } else if (state is AddressLoaded ||
                state is AddressOperationSuccess) {
              List<UserAddressModel> addresses = [];
              if (state is AddressLoaded) {
                addresses = state.userAddresses;
              } else if (state is AddressOperationSuccess) {
                addresses = state.userAddresses;
              }

              return ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  return AddressCard(addressModel: addresses[index]);
                },
              );
            } else if (state is NoAddressFound) {
              return const Center(child: Text("Bạn chưa có địa chỉ nào"));
            } else if (state is AddressError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.addressModel});

  final UserAddressModel addressModel;

  @override
  Widget build(BuildContext context) {
    final addr = addressModel.address!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + Tên + Phone + Badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addr.receiverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(FontAwesomeIcons.phone,
                              size: 12, color: Colors.blue),
                          const SizedBox(width: 6),
                          Text(
                            addr.receiverPhone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (addressModel.isDefault == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Mặc định",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Địa chỉ
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(FontAwesomeIcons.locationDot,
                    size: 16, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${addr.street}, ${addr.ward}, ${addr.district}, ${addr.province}",
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(thickness: 1, height: 1),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(FontAwesomeIcons.pen, size: 14),
                  label: const Text("Sửa"),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressScreen(
                            isAdd: false, addressModel: addressModel),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  icon: const Icon(FontAwesomeIcons.trash, size: 14),
                  label: const Text("Xóa"),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Xác nhận"),
                          content: const Text(
                              "Bạn có chắc chắn muốn xóa địa chỉ này không?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Hủy"),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Xóa"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      context
                          .read<AddressBloc>()
                          .add(DeleteAddressEvent(addressModel));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
