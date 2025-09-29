class TransactionModel {
  final String id;
  final String transactionDate;
  final String accountNumber;
  final String subAccount;
  final String amountIn;
  final String amountOut;
  final String accumulated;
  final String? code;
  final String transactionContent;
  final String referenceNumber;
  final String bankBrandName;
  final String bankAccountId;

  TransactionModel({
    required this.id,
    required this.transactionDate,
    required this.accountNumber,
    required this.subAccount,
    required this.amountIn,
    required this.amountOut,
    required this.accumulated,
    this.code,
    required this.transactionContent,
    required this.referenceNumber,
    required this.bankBrandName,
    required this.bankAccountId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? "",
      transactionDate: json['transaction_date'] ?? "",
      accountNumber: json['account_number'] ?? "",
      subAccount: json['sub_account'] ?? "",
      amountIn: json['amount_in'] ?? "0",
      amountOut: json['amount_out'] ?? "0",
      accumulated: json['accumulated'] ?? "0",
      code: json['code'],
      transactionContent: json['transaction_content'] ?? "",
      referenceNumber: json['reference_number'] ?? "",
      bankBrandName: json['bank_brand_name'] ?? "",
      bankAccountId: json['bank_account_id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_date': transactionDate,
      'account_number': accountNumber,
      'sub_account': subAccount,
      'amount_in': amountIn,
      'amount_out': amountOut,
      'accumulated': accumulated,
      'code': code,
      'transaction_content': transactionContent,
      'reference_number': referenceNumber,
      'bank_brand_name': bankBrandName,
      'bank_account_id': bankAccountId,
    };
  }

  /// ✅ Trả về TransactionModel rỗng
  static TransactionModel empty() {
    return TransactionModel(
      id: "",
      transactionDate: "",
      accountNumber: "",
      subAccount: "",
      amountIn: "0",
      amountOut: "0",
      accumulated: "0",
      code: null,
      transactionContent: "",
      referenceNumber: "",
      bankBrandName: "",
      bankAccountId: "",
    );
  }

  /// ✅ Copy object và override field mong muốn
  TransactionModel copyWith({
    String? id,
    String? transactionDate,
    String? accountNumber,
    String? subAccount,
    String? amountIn,
    String? amountOut,
    String? accumulated,
    String? code,
    String? transactionContent,
    String? referenceNumber,
    String? bankBrandName,
    String? bankAccountId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      transactionDate: transactionDate ?? this.transactionDate,
      accountNumber: accountNumber ?? this.accountNumber,
      subAccount: subAccount ?? this.subAccount,
      amountIn: amountIn ?? this.amountIn,
      amountOut: amountOut ?? this.amountOut,
      accumulated: accumulated ?? this.accumulated,
      code: code ?? this.code,
      transactionContent: transactionContent ?? this.transactionContent,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      bankBrandName: bankBrandName ?? this.bankBrandName,
      bankAccountId: bankAccountId ?? this.bankAccountId,
    );
  }

  /// ✅ Kiểm tra model có phải empty không
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}
