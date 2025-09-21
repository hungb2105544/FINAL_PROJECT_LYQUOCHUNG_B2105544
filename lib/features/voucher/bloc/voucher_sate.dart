import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
import 'package:equatable/equatable.dart';

abstract class VoucherState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {
  VoucherInitial();
}

class VoucherLoading extends VoucherState {
  final List<VoucherModel> vouchers;
  VoucherLoading({this.vouchers = const []});

  @override
  List<Object?> get props => [vouchers];
}

class VoucherLoaded extends VoucherState {
  final List<VoucherModel> vouchers;
  VoucherLoaded({this.vouchers = const []});

  @override
  List<Object?> get props => [vouchers];
}

class NoVoucherFound extends VoucherState {
  NoVoucherFound();
}

class VoucherError extends VoucherState {
  final String message;
  VoucherError(this.message);

  @override
  List<Object?> get props => [message];
}

class VoucherSuccess extends VoucherState {
  final String message;
  VoucherSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class VoucherSaving extends VoucherState {}

class VoucherSavedSuccess extends VoucherState {}

class VoucherFailure extends VoucherState {
  final String error;
  VoucherFailure(this.error);
}
