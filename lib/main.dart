import 'package:ecommerce_app/home_page.dart';
import 'package:ecommerce_app/theme_app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: appTheme,
        home: HomePage());
  }
}

class DemoThemePage extends StatelessWidget {
  const DemoThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme Demo"),
        actions: const [
          Icon(Icons.shopping_cart),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TextTheme Test ---
            Text("Headline Large",
                style: Theme.of(context).textTheme.headlineLarge),
            Text("Headline Medium",
                style: Theme.of(context).textTheme.headlineMedium),
            Text("Body Large", style: Theme.of(context).textTheme.bodyLarge),
            Text("Body Medium", style: Theme.of(context).textTheme.bodyMedium),
            Text("Label Large", style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 24),

            // --- Button Test ---
            ElevatedButton(
              onPressed: () {},
              child: const Text("Elevated Button"),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text("Outlined Button"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: const Text("Text Button"),
            ),
            const SizedBox(height: 24),

            // --- Input Field Test ---
            TextField(
              decoration: const InputDecoration(
                labelText: "Tên đăng nhập",
                hintText: "Nhập username",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                hintText: "Nhập password",
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // --- Icon Test ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.home, size: 32),
                Icon(Icons.favorite, size: 32),
                Icon(Icons.notifications, size: 32),
                Icon(Icons.settings, size: 32),
              ],
            ),
            const SizedBox(height: 24),

            // --- Card + ListTile Test ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(Icons.shopping_bag),
                title: Text("Sản phẩm"),
                subtitle: Text("Mô tả sản phẩm ngắn"),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            const SizedBox(height: 24),

            // --- Grid Buttons (mô phỏng e-commerce) ---
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: List.generate(4, (index) {
                return ElevatedButton(
                  onPressed: () {},
                  child: Text("Item ${index + 1}"),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
