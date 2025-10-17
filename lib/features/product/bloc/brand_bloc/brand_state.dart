import 'package:equatable/equatable.dart';
import 'package:ecommerce_app/features/product/data/models/brand_model.dart'; // Giả sử BrandModel ở đây

abstract class BrandState extends Equatable {
  const BrandState();

  @override
  List<Object> get props => [];
}

class BrandInitial extends BrandState {}

class BrandLoading extends BrandState {}

class BrandLoaded extends BrandState {
  final List<BrandModel> brands;

  const BrandLoaded({required this.brands});

  @override
  List<Object> get props => [brands];
}

class BrandError extends BrandState {
  final String message;

  const BrandError({required this.message});

  @override
  List<Object> get props => [message];
}
