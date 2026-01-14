class QuerySpecBuilder {
  final Map<String, dynamic> _spec = {};

  QuerySpecBuilder fields(List<String> fields) {
    _spec['fields'] = fields;
    return this;
  }

  QuerySpecBuilder where(String field, String operator, dynamic value) {
    _spec.putIfAbsent('filters', () => <List<dynamic>>[]);
    (_spec['filters'] as List).add([field, operator, value]);
    return this;
  }

  QuerySpecBuilder orderBy(String field, {String direction = 'asc'}) {
    _spec.putIfAbsent('order_by', () => <List<dynamic>>[]);
    (_spec['order_by'] as List).add([field, direction]);
    return this;
  }

  QuerySpecBuilder page(int page) {
    _spec['page'] = page;
    return this;
  }

  QuerySpecBuilder limit(int limit) {
    _spec['limit'] = limit;
    return this;
  }

  Map<String, dynamic> build() {
    return _spec;
  }
}
