import 'package:ecommerce_app/features/address/data/model/user_address_model.dart';
import 'package:equatable/equatable.dart';

abstract class AddressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddAddressEvent extends AddressEvent {
  final UserAddressModel newAddress;

  AddAddressEvent(this.newAddress);
  @override
  List<Object?> get props => [newAddress];
}

class UpdatedAddress extends AddressEvent {
  final UserAddressModel updatedAddress;
  UpdatedAddress(this.updatedAddress);
}

class LoadAddress extends AddressEvent {
  final String? userId;
  LoadAddress({this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteAddressEvent extends AddressEvent {
  final UserAddressModel address;

  DeleteAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}
