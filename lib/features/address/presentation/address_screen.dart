// import 'dart:convert';

// import 'package:drop_down_list/drop_down_list.dart';
// import 'package:drop_down_list/model/selected_list_item.dart';
// import 'package:ecommerce_app/features/address/bloc/address_bloc.dart';
// import 'package:ecommerce_app/features/address/bloc/address_event.dart';
// import 'package:ecommerce_app/features/address/bloc/address_state.dart';
// import 'package:ecommerce_app/features/address/data/model/district_model.dart';
// import 'package:ecommerce_app/features/address/data/model/province_model.dart';
// import 'package:ecommerce_app/features/address/data/model/ward_model.dart';
// import 'package:ecommerce_app/service/vietnam_api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class AddressScreen extends StatefulWidget {
//   const AddressScreen({super.key, required this.isAdd});
//   final bool isAdd;

//   @override
//   State<AddressScreen> createState() => _AddressScreenState();
// }

// class _AddressScreenState extends State<AddressScreen> {
//   final TextEditingController _nameReciverController = TextEditingController();
//   final TextEditingController _phoneReciverController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _districtController = TextEditingController();
//   final TextEditingController _wardController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   String provinceSelectedCode = '';
//   String wardSelectedCode = '';
//   bool _isDefault = false;

//   @override
//   void dispose() {
//     _nameReciverController.dispose();
//     _phoneReciverController.dispose();
//     _cityController.dispose();
//     _districtController.dispose();
//     _wardController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   void _saveAddress() {
//     if (_nameReciverController.text.isEmpty ||
//         _phoneReciverController.text.isEmpty ||
//         _addressController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
//       );
//       return;
//     }
//     Navigator.pop(context);
//   }

//   Future<void> _showCityDropDown() async {
//     final provinces = await VietnamApiService.getProvinces(depth: 3);

//     final List<SelectedListItem<Province>> provinceList = provinces
//         .map((province) => SelectedListItem<Province>(
//               data: province, // giữ object Province
//               isSelected: false,
//             ))
//         .toList();

//     DropDownState<Province>(
//       dropDown: DropDown<Province>(
//         data: provinceList,
//         onSelected: (List<SelectedListItem<Province>> selectedItems) {
//           if (selectedItems.isNotEmpty) {
//             final Province selectedProvince = selectedItems.first.data!;
//             _cityController.text = selectedProvince.name;
//             print(
//                 "Selected province: ${selectedProvince.name} (${selectedProvince.code})");
//             Future.delayed(Duration(milliseconds: 150), () {
//               _showDistrictDropDown(selectedProvince.code);
//             });
//           }
//         },
//       ),
//     ).showModal(context);
//   }

//   Future<void> _showDistrictDropDown(int code) async {
//     final provinces = await VietnamApiService.getProvince(code, depth: 2);
//     print(provinces.districts);
//     final districts = provinces.districts;
//     final List<SelectedListItem<District>> districtsList = districts
//         .map((district) => SelectedListItem<District>(
//               data: district, // giữ object Province
//               isSelected: false,
//             ))
//         .toList();

//     DropDownState<District>(
//       dropDown: DropDown<District>(
//         data: districtsList,
//         onSelected: (List<SelectedListItem<District>> selectedItems) {
//           if (selectedItems.isNotEmpty) {
//             final District selecteDistrict = selectedItems.first.data!;
//             _districtController.text = selecteDistrict.name; // lấy tên
//             print(
//                 "Selected province: ${selecteDistrict.name} (${selecteDistrict.code})");
//             Future.delayed(Duration(milliseconds: 150), () {
//               _showWardDropDown(selecteDistrict.code);
//             });
//           }
//         },
//       ),
//     ).showModal(context);
//   }

//   Future<void> _showWardDropDown(int code) async {
//     final district = await VietnamApiService.getDistrict(code, depth: 2);
//     final wards = district.wards;
//     final List<SelectedListItem<Ward>> wardsList = wards
//         .map((district) => SelectedListItem<Ward>(
//               data: district, // giữ object Province
//               isSelected: false,
//             ))
//         .toList();

//     DropDownState<Ward>(
//       dropDown: DropDown<Ward>(
//         data: wardsList,
//         onSelected: (List<SelectedListItem<Ward>> selectedItems) {
//           if (selectedItems.isNotEmpty) {
//             final Ward selecteWard = selectedItems.first.data!;
//             _wardController.text = selecteWard.name; // lấy tên
//             print(
//                 "Selected province: ${selecteWard.name} (${selecteWard.code})");
//           }
//         },
//       ),
//     ).showModal(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AddressBloc, AddressState>(
//       builder: (context, state) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("Thông tin chi tiết địa chỉ nhận hàng"),
//           ),
//           body: widget.isAdd
//               ? SafeArea(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text("Tên người nhận"),
//                         TextFormField(controller: _nameReciverController),
//                         const SizedBox(height: 10),
//                         const Text("Số điện thoại"),
//                         TextFormField(
//                           controller: _phoneReciverController,
//                           keyboardType: TextInputType.phone,
//                         ),
//                         const SizedBox(height: 10),
//                         const Text("Tỉnh/Thành phố"),
//                         InkWell(
//                           onTap: _showCityDropDown,
//                           child: IgnorePointer(
//                             child: TextFormField(
//                               controller: _cityController,
//                               decoration: const InputDecoration(
//                                 hintText: 'Chọn tỉnh/thành phố',
//                                 suffixIcon: Icon(Icons.arrow_drop_down),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text("Quận/Huyện"),
//                         InkWell(
//                           onTap: () {},
//                           child: IgnorePointer(
//                             child: TextFormField(
//                               controller: _districtController,
//                               decoration: const InputDecoration(
//                                 hintText: 'Chọn quận/huyện',
//                                 suffixIcon: Icon(Icons.arrow_drop_down),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text("Phường/Xã"),
//                         InkWell(
//                           onTap: () {},
//                           child: IgnorePointer(
//                             child: TextFormField(
//                               controller: _wardController,
//                               decoration: const InputDecoration(
//                                 hintText: 'Chọn phường/xã',
//                                 suffixIcon: Icon(Icons.arrow_drop_down),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text("Địa chỉ chi tiết"),
//                         TextFormField(controller: _addressController),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: _isDefault,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _isDefault = value ?? false;
//                                 });
//                               },
//                             ),
//                             const Text("Đặt làm địa chỉ mặc định")
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _saveAddress,
//                             child: const Text("Lưu địa chỉ"),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : const Center(
//                   child: Text("Đang tiến hành thiết lập"),
//                 ),
//         );
//       },
//     );
//   }
// }
import 'dart:convert';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:ecommerce_app/features/address/bloc/address_bloc.dart';
import 'package:ecommerce_app/features/address/bloc/address_event.dart';
import 'package:ecommerce_app/features/address/bloc/address_state.dart';
import 'package:ecommerce_app/features/address/data/model/district_model.dart';
import 'package:ecommerce_app/features/address/data/model/province_model.dart';
import 'package:ecommerce_app/features/address/data/model/ward_model.dart';
import 'package:ecommerce_app/service/vietnam_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key, required this.isAdd});
  final bool isAdd;

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _nameReciverController = TextEditingController();
  final TextEditingController _phoneReciverController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? provinceSelectedCode;
  String? districtSelectedCode;
  String? wardSelectedCode;
  bool _isDefault = false;

  @override
  void dispose() {
    _nameReciverController.dispose();
    _phoneReciverController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_nameReciverController.text.isEmpty ||
        _phoneReciverController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }
    Navigator.pop(context);
  }

  /// Reset District + Ward khi đổi Province
  void _resetDistrictAndWard() {
    _districtController.clear();
    _wardController.clear();
    districtSelectedCode = null;
    wardSelectedCode = null;
  }

  /// Reset Ward khi đổi District
  void _resetWard() {
    _wardController.clear();
    wardSelectedCode = null;
  }

  /// Helper: chuyển List<T> -> List<SelectedListItem<T>>
  List<SelectedListItem<T>> _mapToSelectedList<T>(List<T> items) {
    return items
        .map((item) => SelectedListItem<T>(data: item, isSelected: false))
        .toList();
  }

  Future<void> _showCityDropDown() async {
    final provinces = await VietnamApiService.getProvinces(depth: 1);
    final provinceList = _mapToSelectedList(provinces);

    DropDownState<Province>(
      dropDown: DropDown<Province>(
        data: provinceList,
        onSelected: (selectedItems) {
          if (selectedItems.isNotEmpty) {
            final selectedProvince = selectedItems.first.data!;
            setState(() {
              _cityController.text = selectedProvince.name;
              provinceSelectedCode = selectedProvince.code.toString();
              _resetDistrictAndWard();
            });
            _showDistrictDropDown(selectedProvince.code);
          }
        },
      ),
    ).showModal(context);
  }

  Future<void> _showDistrictDropDown(int provinceCode) async {
    final province =
        await VietnamApiService.getProvince(provinceCode, depth: 2);
    final districtsList = _mapToSelectedList(province.districts);

    DropDownState<District>(
      dropDown: DropDown<District>(
        data: districtsList,
        onSelected: (selectedItems) {
          if (selectedItems.isNotEmpty) {
            final selectedDistrict = selectedItems.first.data!;
            setState(() {
              _districtController.text = selectedDistrict.name;
              districtSelectedCode = selectedDistrict.code.toString();
              _resetWard();
            });
            _showWardDropDown(selectedDistrict.code);
          }
        },
      ),
    ).showModal(context);
  }

  Future<void> _showWardDropDown(int districtCode) async {
    final district =
        await VietnamApiService.getDistrict(districtCode, depth: 2);
    final wardsList = _mapToSelectedList(district.wards);

    DropDownState<Ward>(
      dropDown: DropDown<Ward>(
        data: wardsList,
        onSelected: (selectedItems) {
          if (selectedItems.isNotEmpty) {
            final selectedWard = selectedItems.first.data!;
            setState(() {
              _wardController.text = selectedWard.name;
              wardSelectedCode = selectedWard.code.toString();
            });
          }
        },
      ),
    ).showModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: widget.isAdd
                ? Text("Thêm địa chỉ mới")
                : Text("Thông tin chi tiết địa chỉ nhận hàng"),
          ),
          body: widget.isAdd
              ? SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tên người nhận"),
                        TextFormField(controller: _nameReciverController),
                        const SizedBox(height: 10),
                        const Text("Số điện thoại"),
                        TextFormField(
                          controller: _phoneReciverController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 10),
                        const Text("Tỉnh/Thành phố"),
                        InkWell(
                          onTap: _showCityDropDown,
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                hintText: 'Chọn tỉnh/thành phố',
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("Quận/Huyện"),
                        InkWell(
                          onTap: () {
                            if (provinceSelectedCode != null) {
                              _showDistrictDropDown(
                                  int.parse(provinceSelectedCode!));
                            }
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: _districtController,
                              decoration: const InputDecoration(
                                hintText: 'Chọn quận/huyện',
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("Phường/Xã"),
                        InkWell(
                          onTap: () {
                            if (districtSelectedCode != null) {
                              _showWardDropDown(
                                  int.parse(districtSelectedCode!));
                            }
                          },
                          child: IgnorePointer(
                            child: TextFormField(
                              controller: _wardController,
                              decoration: const InputDecoration(
                                hintText: 'Chọn phường/xã',
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("Địa chỉ chi tiết"),
                        TextFormField(controller: _addressController),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _isDefault,
                              onChanged: (value) {
                                setState(() {
                                  _isDefault = value ?? false;
                                });
                              },
                            ),
                            const Text("Đặt làm địa chỉ mặc định")
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveAddress,
                            child: const Text("Lưu địa chỉ"),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: Text("Đang tiến hành thiết lập"),
                ),
        );
      },
    );
  }
}
