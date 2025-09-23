import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_bloc.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_event.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_sate.dart';
import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
import 'package:ecommerce_app/features/voucher/widget/filter_sumary.dart';
import 'package:ecommerce_app/features/voucher/widget/voucher_card.dart';
import 'package:ecommerce_app/features/voucher/widget/voucher_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserVoucherPage extends StatefulWidget {
  const UserVoucherPage({super.key});

  @override
  State<UserVoucherPage> createState() => _UserVoucherPageState();
}

class _UserVoucherPageState extends State<UserVoucherPage> {
  String selectedType = 'all';
  String selectedStatus = 'all';
  String? userId;

  @override
  void initState() {
    super.initState();
    final currentUser = SupabaseConfig.client.auth.currentUser;
    if (currentUser != null) {
      userId = currentUser.id;
      context.read<VoucherBloc>().add(GetVoucherByUserId(userId!));
    }
  }

  List<VoucherModel> _applyFilters(List<VoucherModel> vouchers) {
    return vouchers.where((voucher) {
      bool typeMatch = selectedType == 'all' || voucher.type == selectedType;
      bool statusMatch = true;
      if (selectedStatus == 'saved') {
        statusMatch = voucher.isSaved;
      } else if (selectedStatus == 'not_saved') {
        statusMatch = !voucher.isSaved;
      } else if (selectedStatus == 'expired') {
        statusMatch = voucher.validTo.isBefore(DateTime.now());
      } else if (selectedStatus == 'valid') {
        statusMatch = voucher.validTo.isAfter(DateTime.now());
      }

      return typeMatch && statusMatch;
    }).toList();
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => VoucherFilterWidget(
        selectedType: selectedType,
        selectedStatus: selectedStatus,
        onApply: (type, status) {
          setState(() {
            selectedType = type;
            selectedStatus = status;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Vui lòng đăng nhập để xem voucher")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vouchers của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: BlocBuilder<VoucherBloc, VoucherState>(
        builder: (context, state) {
          if (state is VoucherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VoucherLoaded) {
            final vouchers = _applyFilters(state.vouchers);

            if (vouchers.isEmpty) {
              return Column(
                children: [
                  FilterSummary(
                    selectedType: selectedType,
                    selectedStatus: selectedStatus,
                    onClear: () {
                      setState(() {
                        selectedType = 'all';
                        selectedStatus = 'all';
                      });
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Không tìm thấy voucher nào phù hợp'),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                FilterSummary(
                  selectedType: selectedType,
                  selectedStatus: selectedStatus,
                  onClear: () {
                    setState(() {
                      selectedType = 'all';
                      selectedStatus = 'all';
                    });
                  },
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<VoucherBloc>()
                          .add(GetVoucherByUserId(userId!));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: vouchers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
                      itemBuilder: (context, index) {
                        final voucher = vouchers[index];
                        return VoucherCard(
                          isUserVoucher: true,
                          voucher: voucher,
                          userId: userId!,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else if (state is NoVoucherFound) {
            return const Center(child: Text('Bạn chưa có voucher nào.'));
          } else if (state is VoucherError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
