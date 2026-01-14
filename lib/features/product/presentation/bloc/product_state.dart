part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductListLoading extends ProductState {
  const ProductListLoading();
}

class ProductListLoaded extends ProductState {
  final List<Product> products;
  final int page;
  final int limit;
  final bool hasMore;
  final bool isLoadingMore;
  final String? search;
  final List<List<dynamic>>?
  filters; // ✅ Pakai List<List<dynamic>> biar fleksibel
  final List<List<String>>? orderBy;
  final List<String>? fields;

  const ProductListLoaded({
    required this.products,
    required this.page,
    required this.limit,
    required this.hasMore,
    this.isLoadingMore = false,
    this.search,
    this.filters,
    this.orderBy,
    this.fields,
  });

  ProductListLoaded copyWith({
    List<Product>? products,
    int? page,
    int? limit,
    bool? hasMore,
    bool? isLoadingMore,
    String? search,
    List<List<dynamic>>? filters, // ✅ Pakai List<List<dynamic>>
    List<List<String>>? orderBy,
    List<String>? fields,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      search: search ?? this.search,
      filters: filters ?? this.filters,
      orderBy: orderBy ?? this.orderBy,
      fields: fields ?? this.fields,
    );
  }

  @override
  List<Object?> get props => [
    products,
    page,
    limit,
    hasMore,
    isLoadingMore,
    search,
    filters,
    orderBy,
    fields,
  ];
}

class ProductDetailLoading extends ProductState {
  const ProductDetailLoading();
}

class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductVariantLoading extends ProductState {
  const ProductVariantLoading();
}

class ProductVariantLoaded extends ProductState {
  final VariantEntity variant;

  const ProductVariantLoaded(this.variant);

  @override
  List<Object?> get props => [variant];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
