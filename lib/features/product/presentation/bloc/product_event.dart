part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductEventLoadFirstPage extends ProductEvent {
  final String? search;
  final List<List<dynamic>>? filters;
  final List<List<String>>? orderBy; // ✅ Tetap List<List<String>>
  final List<String>? fields;
  final int? limit;

  const ProductEventLoadFirstPage({
    this.search,
    this.filters,
    this.orderBy,
    this.fields,
    this.limit,
  });

  @override
  List<Object?> get props => [search, filters, orderBy, fields, limit];
}

class ProductEventLoadNextPage extends ProductEvent {
  const ProductEventLoadNextPage();
}

class ProductEventRefresh extends ProductEvent {
  const ProductEventRefresh();
}

class ProductEventGetDetail extends ProductEvent {
  final String productId;

  const ProductEventGetDetail(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ProductEventGetVariant extends ProductEvent {
  final String variantId;

  const ProductEventGetVariant(this.variantId);

  @override
  List<Object?> get props => [variantId];
}

class ProductEventGetHotDeals extends ProductEvent {
  const ProductEventGetHotDeals();
}

class ProductEventClearCache extends ProductEvent {
  const ProductEventClearCache();
}
