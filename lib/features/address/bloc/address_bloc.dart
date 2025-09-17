// Cải tiến cho address_bloc.dart

import 'dart:async';
import 'dart:developer'; // For logging

import 'package:ecommerce_app/features/address/bloc/address_event.dart';
import 'package:ecommerce_app/features/address/bloc/address_state.dart';
import 'package:ecommerce_app/features/address/data/model/user_address_model.dart';
import 'package:ecommerce_app/features/address/data/repositories/user_address_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final UserAddressRepositoryImpl _repository = UserAddressRepositoryImpl();

  AddressBloc() : super(const AddressInitial()) {
    on<LoadAddress>(_getAddress);
    on<UpdatedAddress>(_updateAddress);
    on<AddAddressEvent>(_addAddress);
    on<DeleteAddressEvent>(_deleteAddress);
  }

  Future<void> _getAddress(
      LoadAddress event, Emitter<AddressState> emit) async {
    try {
      final userId = event.userId;

      // Emit loading state - không cần preserve addresses cho load đầu tiên
      emit(const AddressLoading());

      // Validate userId
      if (userId == null || userId.isEmpty) {
        emit(const AddressError("User ID không tồn tại"));
        return;
      }

      // Get addresses
      final addresses = await _repository.getAddress(userId);

      // Check if addresses is empty
      if (addresses.isEmpty) {
        emit(const NoAddressFound());
      } else {
        emit(AddressLoaded(userAddresses: addresses));
      }
    } catch (e) {
      log('Error loading addresses: $e'); // Log for debugging
      emit(_handleError(e, "Lỗi khi tải danh sách địa chỉ"));
    }
  }

  Future<void> _updateAddress(
      UpdatedAddress event, Emitter<AddressState> emit) async {
    try {
      final updatedAddress = event.updatedAddress;
      if (updatedAddress.userId == null || updatedAddress.userId!.isEmpty) {
        emit(const AddressError("Địa chỉ cập nhật không hợp lệ"));
        return;
      }
      final currentAddresses = _getCurrentAddresses();
      final optimisticAddresses = currentAddresses.map((addr) {
        return addr.id == updatedAddress.id ? updatedAddress : addr;
      }).toList();

      emit(AddressLoading(userAddresses: optimisticAddresses));
      await _repository.updateAddress(updatedAddress);

      final addresses = await _repository.getAddress(updatedAddress.userId!);
      emit(AddressLoaded(userAddresses: addresses));

      emit(const AddressSuccess("Cập nhật địa chỉ thành công"));
    } catch (e) {
      log('Error updating address: $e');
      final currentAddresses = _getCurrentAddresses();
      emit(AddressLoaded(userAddresses: currentAddresses));
      emit(_handleError(e, "Lỗi khi cập nhật địa chỉ"));
    }
  }

  Future<void> _addAddress(
      AddAddressEvent event, Emitter<AddressState> emit) async {
    try {
      final newAddress = event.newAddress;
      if (newAddress.userId == null || newAddress.userId!.isEmpty) {
        emit(const AddressError("Địa chỉ mới không hợp lệ"));
        return;
      }
      emit(const AddressLoading());
      await _repository.addAddress(newAddress);
      final addresses = await _repository.getAddress(newAddress.userId!);
      emit(AddressLoaded(userAddresses: addresses));
      emit(const AddressSuccess("Thêm địa chỉ thành công"));
    } catch (e) {
      log('Error adding address: $e');
      emit(_handleError(e, "Lỗi khi thêm địa chỉ"));
    }
  }

  Future<void> _deleteAddress(
      DeleteAddressEvent event, Emitter<AddressState> emit) async {
    try {
      final addressToDelete = event.address;
      if (addressToDelete.userId == null || addressToDelete.userId!.isEmpty) {
        emit(const AddressError(
            "Không thể xóa: thông tin địa chỉ không hợp lệ"));
        return;
      }
      final canDelete = await _repository.canDeleteAddress(addressToDelete);
      if (!canDelete) {
        emit(const AddressError(
            "Không thể xóa địa chỉ này vì đã được sử dụng trong đơn hàng"));
        return;
      }
      final currentAddresses = _getCurrentAddresses();
      final optimisticAddresses = currentAddresses
          .where((addr) => addr.id != addressToDelete.id)
          .toList();
      emit(AddressLoading(userAddresses: optimisticAddresses));
      bool wasDefault = addressToDelete.isDefault;
      await _repository.deleteAddress(addressToDelete);
      if (wasDefault && optimisticAddresses.isNotEmpty) {
        final newDefaultAddress =
            optimisticAddresses.first.copyWith(isDefault: true);
        await _repository.updateAddress(newDefaultAddress);
      }
      final addresses = await _repository.getAddress(addressToDelete.userId!);
      if (addresses.isEmpty) {
        emit(const NoAddressFound());
      } else {
        emit(AddressLoaded(userAddresses: addresses));
        emit(const AddressSuccess("Xóa địa chỉ thành công"));
      }
    } catch (e) {
      log('Error deleting address: $e');
      final currentAddresses = _getCurrentAddresses();
      emit(AddressLoaded(userAddresses: currentAddresses));
      emit(_handleError(e, "Lỗi khi xóa địa chỉ"));
    }
  }

  List<UserAddressModel> _getCurrentAddresses() {
    final currentState = state;
    if (currentState is AddressLoaded) {
      return currentState.userAddresses;
    } else if (currentState is AddressLoading) {
      return currentState.userAddresses;
    }
    return [];
  }

  AddressError _handleError(dynamic error, String defaultMessage) {
    if (error.toString().contains('network')) {
      return const AddressError("Lỗi kết nối mạng. Vui lòng thử lại.");
    } else if (error.toString().contains('timeout')) {
      return const AddressError("Kết nối timeout. Vui lòng thử lại.");
    } else if (error.toString().contains('unauthorized')) {
      return const AddressError("Phiên đăng nhập đã hết hạn.");
    }
    return AddressError(defaultMessage);
  }
}
