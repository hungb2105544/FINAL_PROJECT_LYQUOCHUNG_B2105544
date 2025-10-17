import 'package:equatable/equatable.dart';

sealed class ProductTypeEvent extends Equatable {
  const ProductTypeEvent();

  @override
  List<Object> get props => [];
}

final class FetchProductTypes extends ProductTypeEvent {
  const FetchProductTypes();
}

final class RefreshProductTypes extends ProductTypeEvent {
  const RefreshProductTypes();
}
