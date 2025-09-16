import 'package:ecommerce_app/features/address/data/model/ward_model.dart';
import 'package:ecommerce_app/features/address/presentation/address_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddressUserScreen extends StatefulWidget {
  const AddressUserScreen({super.key});

  @override
  State<AddressUserScreen> createState() => _AddressUserScreenState();
}

class _AddressUserScreenState extends State<AddressUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Địa chỉ người dùng"),
      ),
      floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddressScreen(
                          isAdd: true,
                        )));
          },
          child: const Icon(FontAwesomeIcons.add)),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return AddressCard();
        },
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  const AddressCard({super.key});
  final String? reciverName = 'Ly Quoc Hung';
  final String? reciverPhone = '038223519';
  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddressScreen(
                      isAdd: false,
                    )));
      },
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              FontAwesomeIcons.person,
              size: 15,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                "${widget.reciverName}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // … nếu quá dài
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Icon(
              FontAwesomeIcons.phone,
              size: 10,
            ),
            SizedBox(
              width: 10,
            ),
            Text("${widget.reciverPhone}")
          ],
        ),
        subtitle: Text(
          "Dia chi nhan hangasdasdgashgdjahsgdjashgdjahsgdkjagfkajsdgfasdfgasidfgaisgdfiausgdfiusgdighfasdkfhakjsdhfakjshdfkjhsdjk",
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }
}
