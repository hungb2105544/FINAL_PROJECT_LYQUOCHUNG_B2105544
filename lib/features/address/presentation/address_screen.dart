import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/address/bloc/address_bloc.dart';
import 'package:ecommerce_app/features/address/bloc/address_state.dart';
import 'package:ecommerce_app/features/address/data/model/address_model.dart';
import 'package:ecommerce_app/features/address/data/model/district_model.dart';
import 'package:ecommerce_app/features/address/data/model/location_model.dart';
import 'package:ecommerce_app/features/address/data/model/province_model.dart';
import 'package:ecommerce_app/features/address/data/model/user_address_model.dart';
import 'package:ecommerce_app/features/address/data/model/ward_model.dart';
import 'package:ecommerce_app/service/vietnam_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecommerce_app/features/address/bloc/address_event.dart';

class AddressScreen extends StatefulWidget {
  AddressScreen({super.key, required this.isAdd, this.addressModel});
  final bool isAdd;
  UserAddressModel? addressModel;
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
  LatLng? _selectedLocation;
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

  void _updateAddress() {
    print('${widget.addressModel!.toJson()}');
    if (_nameReciverController.text.isEmpty ||
        _phoneReciverController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _wardController.text.isEmpty ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }
    final AddressModel updatedAddress = AddressModel(
      id: widget.addressModel!.address!.id,
      street: _addressController.text,
      ward: _wardController.text,
      district: _districtController.text,
      province: _cityController.text,
      receiverName: _nameReciverController.text,
      receiverPhone: _phoneReciverController.text,
      locationId: widget.addressModel!.address!.locationId,
      createdAt: widget.addressModel!.address!.createdAt,
      updatedAt: DateTime.now(),
      location: LocationModel(
        id: widget.addressModel!.address!.locationId,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      ),
    );
    final UserAddressModel updatedUserAddress = widget.addressModel!
        .copyWith(address: updatedAddress, isDefault: _isDefault);
    context.read<AddressBloc>().add(UpdatedAddress(updatedUserAddress));
    final client = SupabaseConfig.client;
    final String useId = client.auth.currentUser!.id;
    context.read<AddressBloc>().add(LoadAddress(userId: useId));
    Navigator.pop(context, true);
  }

  void _saveAddress() {
    if (_nameReciverController.text.isEmpty ||
        _phoneReciverController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _wardController.text.isEmpty ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }
    final AddressModel newAddress = AddressModel(
      street: _addressController.text,
      ward: _wardController.text,
      district: _districtController.text,
      province: _cityController.text,
      receiverName: _nameReciverController.text,
      receiverPhone: _phoneReciverController.text,
      location: LocationModel(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      ),
    );
    final client = SupabaseConfig.client;
    final String useId = client.auth.currentUser!.id;
    final UserAddressModel userAddress = UserAddressModel(
      userId: useId,
      address: newAddress,
      isDefault: _isDefault,
    );
    context.read<AddressBloc>().add(AddAddressEvent(userAddress));
    Navigator.pop(context, true);
  }

  void _resetDistrictAndWard() {
    _districtController.clear();
    _wardController.clear();
    districtSelectedCode = null;
    wardSelectedCode = null;
  }

  void _resetWard() {
    _wardController.clear();
    wardSelectedCode = null;
  }

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
        onSelected: (selectedItems) async {
          if (selectedItems.isNotEmpty) {
            final selectedProvince = selectedItems.first.data!;
            setState(() {
              _cityController.text = selectedProvince.name;
              provinceSelectedCode = selectedProvince.code.toString();
              _resetDistrictAndWard();
            });
            await Future.delayed(const Duration(milliseconds: 300));
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
        onSelected: (selectedItems) async {
          if (selectedItems.isNotEmpty) {
            final selectedDistrict = selectedItems.first.data!;
            setState(() {
              _districtController.text = selectedDistrict.name;
              districtSelectedCode = selectedDistrict.code.toString();
              _resetWard();
            });
            await Future.delayed(const Duration(milliseconds: 300));
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

  void _onLocationSelected(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã chọn vị trí: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isAdd && widget.addressModel != null) {
      final addr = widget.addressModel!.address!;
      _nameReciverController.text = addr.receiverName ?? '';
      _phoneReciverController.text = addr.receiverPhone ?? '';
      _cityController.text = addr.province ?? '';
      _districtController.text = addr.district ?? '';
      _wardController.text = addr.ward ?? '';
      _addressController.text = addr.street ?? '';
      _isDefault = widget.addressModel!.isDefault;
      if (addr.location != null) {
        final lat = addr.location!.latitude;
        final lng = addr.location!.longitude;
        if (lat != null && lng != null) {
          _selectedLocation = LatLng(lat.toDouble(), lng.toDouble());
        }
      }
    }
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
            body: SafeArea(
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
                          _showWardDropDown(int.parse(districtSelectedCode!));
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
                    const SizedBox(height: 10),
                    TextFormField(controller: _addressController),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          "Vị trí trên bản đồ",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.red[600],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Minimap widget
                    LocationMinimap(
                      height: 150,
                      initialLocation: _selectedLocation,
                      onLocationSelected: _onLocationSelected,
                    ),
                    SizedBox(height: 20),
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
                        onPressed: widget.addressModel != null && !widget.isAdd
                            ? _updateAddress
                            : _saveAddress,
                        child: widget.isAdd
                            ? const Text("Lưu địa chỉ")
                            : const Text("Cập nhật địa chỉ"),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}

class LocationMinimap extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng)? onLocationSelected;
  final double height;
  final double width;

  const LocationMinimap({
    Key? key,
    this.initialLocation,
    this.onLocationSelected,
    this.height = 120,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  State<LocationMinimap> createState() => _LocationMinimapState();
}

class _LocationMinimapState extends State<LocationMinimap> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Kiểm tra quyền truy cập vị trí
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        if (_selectedLocation == null) {
          _selectedLocation = _currentLocation;
        }
      });

      // Di chuyển camera đến vị trí hiện tại
      if (_controller != null && _currentLocation != null) {
        _controller!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    } catch (e) {
      print('Lỗi khi lấy vị trí: $e');
    }
  }

  Future<void> _getCurrentLocationAndUpdate() async {
    try {
      // Hiển thị loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Đang lấy vị trí hiện tại...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Kiểm tra quyền truy cập vị trí
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Cần cấp quyền truy cập vị trí để sử dụng tính năng này'),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng bật quyền truy cập vị trí trong cài đặt'),
          ),
        );
        return;
      }

      // Lấy vị trí hiện tại với độ chính xác cao
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = _currentLocation; // Cập nhật vị trí đã chọn
      });

      // Di chuyển camera đến vị trí hiện tại
      if (_controller != null && _currentLocation != null) {
        _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 16),
        );
      }

      // Gọi callback nếu có
      if (widget.onLocationSelected != null && _selectedLocation != null) {
        widget.onLocationSelected!(_selectedLocation!);
      }

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã cập nhật vị trí hiện tại',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể lấy vị trí hiện tại'),
          backgroundColor: Colors.red,
        ),
      );
      print('Lỗi khi lấy vị trí hiện tại: $e');
    }
  }

  Future<void> _openLocationPicker() async {
    final LatLng? result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialLocation: _selectedLocation ?? _currentLocation,
          currentLocation: _currentLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });

      // Gọi callback nếu có
      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(result);
      }

      // Cập nhật minimap
      if (_controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newLatLng(result),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openLocationPicker,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation ??
                      _currentLocation ??
                      const LatLng(10.762622, 106.660172), // TP.HCM mặc định
                  zoom: 15,
                ),
                markers: _selectedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: _selectedLocation!,
                          infoWindow: const InfoWindow(title: 'Vị trí đã chọn'),
                        ),
                      }
                    : {},
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
              ),
              // Overlay để hiển thị rằng có thể nhấn
              Container(
                color: Colors.transparent,
                child: const Center(
                  child: Icon(
                    Icons.edit_location_alt,
                    color: Colors.white,
                    size: 30,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              // Nút lấy vị trí hiện tại
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    _getCurrentLocationAndUpdate();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  final LatLng? currentLocation;

  const LocationPickerPage({
    Key? key,
    this.initialLocation,
    this.currentLocation,
  }) : super(key: key);

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? widget.currentLocation;
    _updateMarkers();
  }

  void _updateMarkers() {
    _markers.clear();

    if (_selectedLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation!,
          infoWindow: const InfoWindow(title: 'Vị trí đã chọn'),
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              _selectedLocation = newPosition;
            });
          },
        ),
      );
    }

    if (widget.currentLocation != null &&
        widget.currentLocation != _selectedLocation) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: widget.currentLocation!,
          infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _updateMarkers();
    });
  }

  void _goToCurrentLocation() {
    if (widget.currentLocation != null && _controller != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(widget.currentLocation!, 16),
      );
      setState(() {
        _selectedLocation = widget.currentLocation;
        _updateMarkers();
      });
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí'),
        actions: [
          TextButton(
            onPressed: _selectedLocation != null ? _confirmSelection : null,
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ??
                  widget.currentLocation ??
                  const LatLng(10.762622, 106.660172),
              zoom: 16,
            ),
            markers: _markers,
            onTap: _onMapTapped,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          // Nút về vị trí hiện tại
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              mini: true,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          if (_selectedLocation != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vị trí đã chọn:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vĩ độ: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                      ),
                      Text(
                        'Kinh độ: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
