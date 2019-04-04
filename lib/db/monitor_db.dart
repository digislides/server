part of 'db.dart';

class MonitorAccessor {
  Db db;

  MonitorAccessor(this.db);

  DbCollection get col => db.collection('mon');

  Future<String> create(MonitorCreator model, String owner) async {
    final id = idGenerator.generateReadable();
    final query = MonitorCreator.serializer.toMap(model)
      ..addAll({"id": id, "owner": owner});
    await col.insert(query);
    return id;
  }

  Future<String> duplicate(Monitor model) async {
    final id = idGenerator.generateReadable();
    await col.insert(Monitor.serializer.toMap(model)..['id'] = id);
    return id;
  }

  Future<Monitor> get(String id) {
    return col.findOne(where.eq('id', id)).then(Monitor.serializer.fromMap);
  }

  Future<void> save(String id, MonitorCreator data) async {
    final m = modify;
    final v = data.toJson();
    for (String key in v.keys) {
      m.set(key, v[key]);
    }
    await col.update(where.eq('id', id), m);
  }

  Future<void> delete(String id) async {
    await col.remove(where.eq('id', id));
  }

  Future<List<Monitor>> getByUser(String user, {String search: ''}) {
    final b = where.eq('owner', user);
    // TODO also fetch records with write and read access
    // Name search
    if (search != null && search.isNotEmpty) {
      if (!search.contains("^\$")) {
        search = ".*$search.*";
      }
      b.eq("name", {"\$regex": search});
    }
    return col.find(b).map(removeId).map(Monitor.serializer.fromMap).toList();
  }
}
