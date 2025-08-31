import 'package:flutter/material.dart';

class PrivacyPolicyModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: Colors.blue[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Chính sách bảo mật',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          '1. Thu thập thông tin',
                          'Chúng tôi thu thập thông tin khi bạn đăng ký tài khoản, bao gồm:\n\n'
                              '• Thông tin cá nhân: Họ tên, email, số điện thoại\n'
                              '• Thông tin giao dịch: Lịch sử mua hàng, phương thức thanh toán\n'
                              '• Thông tin kỹ thuật: Địa chỉ IP, loại thiết bị, trình duyệt',
                        ),
                        _buildSection(
                          '2. Sử dụng thông tin',
                          'Thông tin của bạn được sử dụng để:\n\n'
                              '• Cung cấp và cải thiện dịch vụ\n'
                              '• Xử lý đơn hàng và giao dịch\n'
                              '• Gửi thông báo quan trọng\n'
                              '• Hỗ trợ khách hàng\n'
                              '• Phân tích và nghiên cứu thị trường',
                        ),
                        _buildSection(
                          '3. Bảo mật thông tin',
                          'Chúng tôi cam kết bảo vệ thông tin của bạn bằng:\n\n'
                              '• Mã hóa SSL/TLS cho tất cả dữ liệu truyền tải\n'
                              '• Hệ thống firewall và bảo mật nhiều lớp\n'
                              '• Kiểm soát truy cập nghiêm ngặt\n'
                              '• Sao lưu dữ liệu định kỳ',
                        ),
                        _buildSection(
                          '4. Chia sẻ thông tin',
                          'Chúng tôi không bán, cho thuê hoặc chia sẻ thông tin cá nhân của bạn với bên thứ ba, trừ khi:\n\n'
                              '• Có sự đồng ý của bạn\n'
                              '• Cần thiết để hoàn thành giao dịch\n'
                              '• Tuân thủ yêu cầu pháp lý\n'
                              '• Bảo vệ quyền lợi hợp pháp của chúng tôi',
                        ),
                        _buildSection(
                          '5. Quyền của người dùng',
                          'Bạn có quyền:\n\n'
                              '• Truy cập và chỉnh sửa thông tin cá nhân\n'
                              '• Yêu cầu xóa tài khoản và dữ liệu\n'
                              '• Từ chối nhận email marketing\n'
                              '• Khiếu nại về việc xử lý dữ liệu',
                        ),
                        _buildSection(
                          '6. Cookies và theo dõi',
                          'Chúng tôi sử dụng cookies để:\n\n'
                              '• Ghi nhớ thông tin đăng nhập\n'
                              '• Cá nhân hóa trải nghiệm\n'
                              '• Phân tích lưu lượng truy cập\n'
                              '• Cải thiện hiệu suất website',
                        ),
                        _buildSection(
                          '7. Liên hệ',
                          'Nếu bạn có câu hỏi về chính sách này, vui lòng liên hệ:\n\n'
                              '• Email: tuilana24723@gmail.com\n'
                              '• Hotline: 0358223519\n'
                              '• Địa chỉ: 60/45b, Trà Ôn, TP.Vĩnh Long',
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Chính sách này có hiệu lực từ ngày 01/01/2024 và có thể được cập nhật theo thời gian.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Đóng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Có thể thêm logic đồng ý ở đây
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Tôi hiểu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget helper để sử dụng trong RichText
class TermsAndConditionsModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Colors.green[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Điều khoản sử dụng',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey[600],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content (simplified for terms)
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          '1. Chấp nhận điều khoản',
                          'Bằng việc sử dụng dịch vụ VIEMODE, bạn đồng ý tuân thủ các điều khoản và điều kiện sau đây.',
                        ),
                        _buildSection(
                          '2. Tài khoản người dùng',
                          'Bạn có trách nhiệm:\n\n'
                              '• Cung cấp thông tin chính xác\n'
                              '• Bảo mật thông tin đăng nhập\n'
                              '• Thông báo kịp thời nếu tài khoản bị xâm phạm\n'
                              '• Chỉ sử dụng một tài khoản duy nhất',
                        ),
                        _buildSection(
                          '3. Sử dụng dịch vụ',
                          'Khi sử dụng dịch vụ, bạn không được:\n\n'
                              '• Vi phạm pháp luật\n'
                              '• Gây thiệt hại đến hệ thống\n'
                              '• Sử dụng cho mục đích thương mại trái phép\n'
                              '• Chia sẻ tài khoản với người khác',
                        ),
                        _buildSection(
                          '4. Quyền sở hữu trí tuệ',
                          'Tất cả nội dung trên VIEMODE được bảo vệ bởi luật bản quyền và là tài sản của chúng tôi.',
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Đóng',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Tôi hiểu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
