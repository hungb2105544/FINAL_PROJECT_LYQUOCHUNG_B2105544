import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/features/address/data/model/user_address_model.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressOperationSuccess extends AddressState {
  final List<UserAddressModel> userAddresses;
  final String message;

  const AddressOperationSuccess(this.userAddresses, this.message);

  @override
  List<Object> get props => [userAddresses, message];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  final List<UserAddressModel> userAddresses;
  const AddressLoading({this.userAddresses = const []});

  @override
  List<Object?> get props => [userAddresses];
}

class AddressLoaded extends AddressState {
  final List<UserAddressModel> userAddresses;
  const AddressLoaded({this.userAddresses = const []});

  @override
  List<Object?> get props => [userAddresses];
}

class NoAddressFound extends AddressState {
  const NoAddressFound();
}

class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressSuccess extends AddressState {
  final String message;
  const AddressSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
