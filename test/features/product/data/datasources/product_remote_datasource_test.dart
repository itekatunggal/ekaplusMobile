import 'dart:convert';

import 'package:ekaplus_ekatunggal/features/product/data/datasources/product_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('ProductRemoteDatasourceImplementation.getAllProduct', () {
    test(
      'keeps a visible variant when the newest variant is disabled',
      () async {
        late Uri requestedUri;
        final client = _TestClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 527,
                  'product_name': 'JASA KAWAT',
                  'disabled': 0,
                  'status': 'Draft',
                  'variants': [
                    {
                      'item': {
                        'id': 1582,
                        'image': 'disabled-image',
                        'disabled': 1,
                        'status': 'Disabled',
                      },
                    },
                    {
                      'item': {
                        'id': 1583,
                        'image': 'visible-image',
                        'disabled': 0,
                        'status': 'Enabled',
                      },
                    },
                  ],
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final datasource = ProductRemoteDatasourceImplementation(
          client: client,
        );

        final products = await datasource.getAllProduct();

        expect(products, hasLength(1));
        expect(products.single.variants, hasLength(1));
        expect(products.single.variants.single.id, 1583);
        expect(products.single.variants.single.image, 'visible-image');

        final spec = jsonDecode(requestedUri.queryParameters['spec']!);
        final childSpec =
            (spec['childs'] as List).single as Map<String, dynamic>;
        expect(childSpec.containsKey('limit'), isFalse);
      },
    );

    test('removes a product variant whose item is disabled', () async {
      final client = _TestClient((request) async {
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 528,
                'product_name': 'JASA SARUNG KASUR',
                'disabled': 0,
                'status': 'Draft',
                'variants': [
                  {
                    'item': {
                      'id': 24298,
                      'image': 'sarung-kasur-image',
                      'disabled': 1,
                      'status': 'Disabled',
                    },
                  },
                ],
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final datasource = ProductRemoteDatasourceImplementation(client: client);

      final products = await datasource.getAllProduct();

      expect(products, hasLength(1));
      expect(products.single.variants, isEmpty);
    });

    test('ignores a disabled variant even when its item is enabled', () async {
      final client = _TestClient((request) async {
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 527,
                'product_name': 'JASA KAWAT',
                'disabled': 0,
                'variants': [
                  {
                    'disabled': 1,
                    'status': 'Disabled',
                    'item': {
                      'id': 1582,
                      'image': 'disabled-variant-image',
                      'disabled': 0,
                      'status': 'Enabled',
                    },
                  },
                  {
                    'disabled': 0,
                    'status': 'Enabled',
                    'item': {
                      'id': 1583,
                      'image': 'enabled-variant-image',
                      'disabled': 0,
                      'status': 'Enabled',
                    },
                  },
                ],
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final datasource = ProductRemoteDatasourceImplementation(client: client);

      final products = await datasource.getAllProduct();

      expect(products.single.variants, hasLength(1));
      expect(products.single.variants.single.id, 1583);
      expect(products.single.variants.single.image, 'enabled-variant-image');
    });
  });
}

class _TestClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  _TestClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      request: request,
    );
  }
}
