import 'package:ecommerce_app/features/voucher/bloc/voucher_event.dart';
import 'package:ecommerce_app/features/voucher/bloc/voucher_sate.dart';
import 'package:ecommerce_app/features/voucher/data/repositories/voucher_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final VoucherRepositoryImpl _voucherRepository;

  VoucherBloc(this._voucherRepository) : super(VoucherInitial()) {
    on<FetchVouchersEvent>(_onFetchVouchers);
    on<SaveVoucherEvent>(_onSaveVoucher);
  }

  void _onFetchVouchers(
      FetchVouchersEvent event, Emitter<VoucherState> emit) async {
    emit(VoucherLoading());
    try {
      final vouchers =
          await _voucherRepository.fetchAvailableVouchers(event.userId);
      if (vouchers.isEmpty) {
        emit(NoVoucherFound());
      } else {
        emit(VoucherLoaded(vouchers: vouchers));
      }
    } catch (e) {
      emit(VoucherError(e.toString()));
    }
  }

  Future<void> _onSaveVoucher(
      SaveVoucherEvent event, Emitter<VoucherState> emit) async {
    if (state is VoucherLoaded) {
      final current = (state as VoucherLoaded).vouchers;
      try {
        await _voucherRepository.saveVoucher(event.userId, event.voucherId);

        final updated = current.map((v) {
          if (v.id == event.voucherId) {
            return v.copyWith(isSaved: true);
          }
          return v;
        }).toList();

        emit(VoucherLoaded(vouchers: updated));
      } catch (e) {
        emit(VoucherError("Không thể lưu voucher: $e"));
        emit(VoucherLoaded(vouchers: current));
      }
    }
  }
}
