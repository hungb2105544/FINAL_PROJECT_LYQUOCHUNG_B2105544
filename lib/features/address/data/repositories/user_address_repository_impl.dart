import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/address/data/model/user_address_model.dart';
import 'package:ecommerce_app/features/address/domain/repositories/user_address_repository.dart';

class UserAddressRepositoryImpl implements UserAddressRepository {
  final client = SupabaseConfig.client;
  @override
  Future<void> addAddress(UserAddressModel newAddress) async {
    try {
      int? locationId;
      if (newAddress.address?.location != null) {
        final locationRes = await client
            .from('locations')
            .insert({
              'latitude': newAddress.address!.location!.latitude,
              'longitude': newAddress.address!.location!.longitude,
            })
            .select('id')
            .single();
        locationId = locationRes['id'] as int;
      }

      final addressRes = await client
          .from('addresses')
          .insert({
            'street': newAddress.address?.street,
            'ward': newAddress.address?.ward,
            'district': newAddress.address?.district,
            'province': newAddress.address?.province,
            'receiver_name': newAddress.address?.receiverName,
            'receiver_phone': newAddress.address?.receiverPhone,
            'location_id': locationId,
            'is_active': newAddress.address?.isActive ?? true,
          })
          .select('id')
          .single();

      final addressId = addressRes['id'] as int;

      if (newAddress.isDefault) {
        await client.from('user_addresses').update({'is_default': false}).eq(
            'user_id', newAddress.userId as String);
      }

      await client.from('user_addresses').insert({
        'user_id': newAddress.userId,
        'address_id': addressId,
        'is_default': newAddress.isDefault,
      });
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  @override
  Future<void> updateAddress(UserAddressModel updatedAddress) async {
    try {
      if (updatedAddress.isDefault) {
        await client.from('user_addresses').update({'is_default': false}).eq(
            'user_id', updatedAddress.userId as String);
      }

      if (updatedAddress.address?.location != null) {
        await client.from('locations').update({
          'latitude': updatedAddress.address!.location!.latitude,
          'longitude': updatedAddress.address!.location!.longitude,
        }).eq('id', updatedAddress.address!.location!.id);
      }

      if (updatedAddress.address != null) {
        await client.from('addresses').update({
          'street': updatedAddress.address!.street,
          'ward': updatedAddress.address!.ward,
          'district': updatedAddress.address!.district,
          'province': updatedAddress.address!.province,
          'receiver_name': updatedAddress.address!.receiverName,
          'receiver_phone': updatedAddress.address!.receiverPhone,
          'is_active': updatedAddress.address!.isActive,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', updatedAddress.address!.id);
      }

      await client.from('user_addresses').update({
        'is_default': updatedAddress.isDefault,
        'address_id': updatedAddress.addressId,
      }).eq('id', updatedAddress.id);
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  @override
  Future<List<UserAddressModel>> getAddress(String userId) async {
    try {
      final response = await client
          .from('user_addresses')
          .select('''
          id,
          user_id,
          address_id,
          is_default,
          created_at,
          address: addresses (
            id,
            street,
            ward,
            district,
            province,
            receiver_name,
            receiver_phone,
            is_active,
            location: locations (
              id,
              latitude,
              longitude
            )
          )
        ''')
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => UserAddressModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }
}
