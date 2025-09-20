import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/address/bloc/address_event.dart';
import 'package:ecommerce_app/features/address/bloc/address_state.dart';
import 'package:ecommerce_app/features/address/data/repositories/user_address_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final UserAddressRepositoryImpl _addressRepository;

  AddressBloc(this._addressRepository) : super(AddressInitial()) {
    on<LoadAddress>(_onLoadAddress);
    on<AddAddressEvent>(_onAddAddress);
    on<UpdatedAddress>(_onUpdateAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
  }

  void _onLoadAddress(LoadAddress event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final addresses = await _addressRepository.getAddress(event.userId!);
      if (addresses.isEmpty) {
        emit(NoAddressFound());
      } else {
        emit(AddressLoaded(userAddresses: addresses));
      }
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  void _onAddAddress(AddAddressEvent event, Emitter<AddressState> emit) async {
    try {
      await _addressRepository.addAddress(event.newAddress);

      final client = SupabaseConfig.client;
      final String userId = client.auth.currentUser!.id;
      final freshAddresses = await _addressRepository.getAddress(userId);

      if (freshAddresses.isEmpty) {
        emit(NoAddressFound());
      } else {
        emit(AddressLoaded(userAddresses: freshAddresses));
        emit(
            AddressOperationSuccess(freshAddresses, "Thêm địa chỉ thành công"));
      }
    } catch (e) {
      emit(AddressError("Không thể thêm địa chỉ: ${e.toString()}"));
    }
  }

  void _onUpdateAddress(
      UpdatedAddress event, Emitter<AddressState> emit) async {
    try {
      await _addressRepository.updateAddress(event.updatedAddress);

      final client = SupabaseConfig.client;
      final String userId = client.auth.currentUser!.id;
      final freshAddresses = await _addressRepository.getAddress(userId);

      if (freshAddresses.isEmpty) {
        emit(NoAddressFound());
      } else {
        emit(AddressLoaded(userAddresses: freshAddresses));
        emit(AddressOperationSuccess(
            freshAddresses, "Cập nhật địa chỉ thành công"));
      }
    } catch (e) {
      emit(AddressError("Không thể cập nhật địa chỉ: ${e.toString()}"));
    }
  }

  void _onDeleteAddress(
      DeleteAddressEvent event, Emitter<AddressState> emit) async {
    try {
      await _addressRepository.deleteAddress(event.address);

      final client = SupabaseConfig.client;
      final String userId = client.auth.currentUser!.id;
      final freshAddresses = await _addressRepository.getAddress(userId);

      if (freshAddresses.isEmpty) {
        emit(NoAddressFound());
      } else {
        emit(AddressLoaded(userAddresses: freshAddresses));
        emit(AddressOperationSuccess(freshAddresses, "Xóa địa chỉ thành công"));
      }
    } catch (e) {
      emit(AddressError("Không thể xóa địa chỉ: ${e.toString()}"));
    }
  }
}
