import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/presentation/widgets/wishlist_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selection toolbar reflects selected wishlist items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WishlistListView(
            userId: 1,
            wishlistItems: [_wishlistItem(101), _wishlistItem(102)],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('wishlist-select-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('wishlist-select-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('wishlist-selection-toolbar')), findsOneWidget);
    expect(find.text('0 dari 2 item dipilih'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('wishlist-card-tap-101')));
    await tester.pumpAndSettle();

    expect(find.text('1 dari 2 item dipilih'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('wishlist-bulk-delete-button')),
          )
          .onPressed,
      isNotNull,
    );
  });
}

WishlistItem _wishlistItem(int productId) {
  return WishlistItem(
    id: productId,
    createdAt: DateTime(2026),
    item: WishlistItemProduct(
      id: productId,
      image: '',
      itemCode: 'ITEM-$productId',
      itemName: 'Produk $productId',
    ),
    user: const WishlistItemUser(id: 1, fullName: 'Pengguna'),
  );
}
