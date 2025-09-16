import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key, required this.isAdd});
  final bool isAdd;
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _nameReciverController = TextEditingController();
  final TextEditingController _phoneReciverController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _nameReciverController.dispose();
    _phoneReciverController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin chi tiết địa chỉ nhận hàng"),
      ),
      body: widget.isAdd
          ? SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    color: Colors.greenAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tên người nhận"),
                        TextFormField(
                          controller: _nameReciverController,
                        ),
                        const Text("Số diện thoại"),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _phoneReciverController,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: const Text(" Đang tiến hành thiết lập"),
            ),
    );
  }
}
