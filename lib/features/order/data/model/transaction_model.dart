class TransactionModel {
  final String id;
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

  /// Parse từ JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? "",
      accountNumber: json['account_number']?.toString() ?? "",
      subAccount: json['sub_account']?.toString() ?? "",
      amountIn: json['amount_in']?.toString() ?? "0",
      amountOut: json['amount_out']?.toString() ?? "0",
      accumulated: json['accumulated']?.toString() ?? "0",
      code: json['code']?.toString(),
      transactionContent: json['transaction_content']?.toString() ?? "",
      referenceNumber: json['reference_number']?.toString() ?? "",
      bankBrandName: json['bank_brand_name']?.toString() ?? "",
      bankAccountId: json['bank_account_id']?.toString() ?? "",
    );
  }

  /// Convert sang JSON (DateTime sẽ thành chuỗi ISO8601)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

  /// Model rỗng
  static TransactionModel empty() {
    return TransactionModel(
      id: "",
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

  /// Copy object
  TransactionModel copyWith({
    String? id,
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

  /// Kiểm tra empty
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Override toString
  @override
  String toString() {
    return 'TransactionModel(id: $id, date: , '
        'account: $accountNumber, amountIn: $amountIn, amountOut: $amountOut, '
        'reference: $referenceNumber, bank: $bankBrandName)';
  }
}
