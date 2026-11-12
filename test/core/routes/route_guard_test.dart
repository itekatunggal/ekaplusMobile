import 'package:ekaplus_ekatunggal/core/routes/route_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guest diarahkan ke login saat membuka customer secara langsung', () {
    expect(
      resolveAppRedirect(
        path: '/customer',
        sessionResolved: true,
        authenticated: false,
      ),
      '/login',
    );
    expect(
      resolveAppRedirect(
        path: '/customer/points',
        sessionResolved: true,
        authenticated: false,
      ),
      '/login',
    );
  });

  test('customer dapat dibuka setelah login', () {
    expect(
      resolveAppRedirect(
        path: '/customer',
        sessionResolved: true,
        authenticated: true,
      ),
      isNull,
    );
  });

  test('session restore tidak dialihkan sebelum status session diketahui', () {
    expect(
      resolveAppRedirect(
        path: '/customer',
        sessionResolved: false,
        authenticated: false,
      ),
      isNull,
    );
  });

  test('route produk tersembunyi tetap diarahkan ke Home', () {
    expect(
      resolveAppRedirect(
        path: '/products/10',
        sessionResolved: true,
        authenticated: true,
      ),
      '/',
    );
  });
}
