import 'package:ekaplus_ekatunggal/features/sales_directory/data/repositories/mock_sales_directory_repository.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/cubit/sales_directory_cubit.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/cubit/sales_directory_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'changing branch replaces profiles instead of retaining old rows',
    () async {
      final cubit = SalesDirectoryCubit(
        MockSalesDirectoryRepository(useRemote: false),
      );
      await cubit.load(branchId: 10);
      expect(cubit.state.profiles.every((row) => row.branchId == 10), isTrue);

      await cubit.load(branchId: 20);

      expect(cubit.state.status, SalesDirectoryStatus.ready);
      expect(cubit.state.branchId, 20);
      expect(cubit.state.profiles.every((row) => row.branchId == 20), isTrue);
      await cubit.close();
    },
  );
}
