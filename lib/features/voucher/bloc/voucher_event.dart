import 'package:equatable/equatable.dart';

class VoucherEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchVouchersEvent extends VoucherEvent {
  final String userId;
  FetchVouchersEvent(this.userId);
}

class SaveVoucherEvent extends VoucherEvent {
  final String userId;
  final String voucherId;
  SaveVoucherEvent(this.userId, this.voucherId);
}

class GetVoucherByUserId extends VoucherEvent {
  final String userId;
  GetVoucherByUserId(this.userId);
}
