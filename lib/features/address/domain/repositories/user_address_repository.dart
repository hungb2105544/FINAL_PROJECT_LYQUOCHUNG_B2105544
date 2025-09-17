import 'package:ecommerce_app/features/address/data/model/user_address_model.dart';

abstract class UserAddressRepository {
  Future<List<UserAddressModel>> getAddress(String userId);
  Future<void> addAddress(UserAddressModel newAddress);
  Future<void> updateAddress(UserAddressModel updatedAddress);
  Future<void> deleteAddress(UserAddressModel address);
  Future<bool> canDeleteAddress(UserAddressModel address);
}
