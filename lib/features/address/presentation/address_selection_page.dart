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

class AddressSelectionPage extends StatefulWidget {
  const AddressSelectionPage({Key? key}) : super(key: key);

  @override
  State<AddressSelectionPage> createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final client = SupabaseConfig.client;
      final String userId = client.auth.currentUser!.id;
      context.read<AddressBloc>().add(LoadAddress(userId: userId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = SupabaseConfig.client;
    final String userId = client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn địa chỉ giao hàng"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddressScreen(isAdd: true),
            ),
          );
          if (result == true) {
            context.read<AddressBloc>().add(LoadAddress(userId: userId));
          }
        },
        child: const Icon(FontAwesomeIcons.add),
      ),
      body: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          if (state is AddressLoading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/loading_viemode.json',
                width: 100,
                height: 100,
              ),
            );
          } else if (state is AddressLoaded ||
              state is AddressOperationSuccess) {
            List<UserAddressModel> addresses = [];
            if (state is AddressLoaded) {
              addresses = state.userAddresses;
            } else if (state is AddressOperationSuccess) {
              addresses = state.userAddresses;
            }

            if (addresses.isEmpty) {
              return const Center(child: Text("Bạn chưa có địa chỉ nào"));
            }

            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final addressModel = addresses[index];
                final addr = addressModel.address!;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.pop(context, addressModel);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(FontAwesomeIcons.phone,
                                            size: 12, color: Colors.blue),
                                        const SizedBox(width: 6),
                                        Text(
                                          addr.receiverPhone,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (addressModel.isDefault == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
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
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.4),
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
                              Text(
                                "Chọn địa chỉ này",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Theme.of(context).primaryColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is AddressError) {
            return Center(child: Text("Lỗi: ${state.message}"));
          } else if (state is NoAddressFound) {
            return const Center(child: Text("Bạn chưa có địa chỉ nào"));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
