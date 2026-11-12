import 'package:ekaplus_ekatunggal/core/utils/debouncer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hanya menjalankan aksi terakhir dalam rentang debounce', () async {
    final debouncer = Debouncer(delay: const Duration(milliseconds: 10));
    final calls = <int>[];

    debouncer.run(() => calls.add(1));
    debouncer.run(() => calls.add(2));
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(calls, [2]);
    debouncer.dispose();
  });

  test('cancel dan dispose mencegah aksi tertunda', () async {
    final debouncer = Debouncer(delay: const Duration(milliseconds: 10));
    var called = false;

    debouncer.run(() => called = true);
    debouncer.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(called, isFalse);
    debouncer.dispose();
  });
}
