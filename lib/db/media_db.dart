part of 'db.dart';

class MediaImageAccessor {
  Db db;

  MediaImageAccessor(this.db);

  DbCollection get col => db.collection('mimg');

  Future<String> create(MediaImage model) async {
    final id = model.id ?? idGenerator.generateReadable();
    final query = MediaImage.serializer.toMap(model)
      ..addAll({
        "id": id,
      });
    await col.insert(query);
    return id;
  }

  Future<MediaImage> get(String id) {
    return col
        .findOne(where.eq('id', id))
        .then(removeId)
        .then(MediaImage.serializer.fromMap);
  }

  Future<List<MediaImage>> getByUser(String user, {String search: ''}) {
    final b = where.eq('owner', user);
    // TODO also fetch records with write and read access
    // Name search
    if (search != null && search.isNotEmpty) {
      if (!search.contains("^\$")) {
        search = ".*$search.*";
      }
      b.eq("name", {"\$regex": search});
    }
    return col
        .find(b)
        .map(removeId)
        .map(MediaImage.serializer.fromMap)
        .toList();
  }

  Future<void> save(String id, MediaCreator data) async {
    final m = modify;
    final json = data.toJson();
    for (String key in json.keys) {
      m.set(key, json[key]);
    }
    await col.update(where.eq('id', id), m);
  }

  Future<void> setOwner(String id, String owner) async {
    await col.update(where.eq('id', id), modify.set('owner', owner));
  }

  Future<void> delete(String id) async {
    await col.remove(where.eq('id', id));
  }
}

class MediaVideoAccessor {
  Db db;

  MediaVideoAccessor(this.db);

  DbCollection get col => db.collection('mvid');

  Future<String> create(MediaVideo model) async {
    final id = model.id ?? idGenerator.generateReadable();
    final query = MediaVideo.serializer.toMap(model)
      ..addAll({
        "id": id,
      });
    await col.insert(query);
    return id;
  }

  Future<MediaVideo> get(String id) {
    return col
        .findOne(where.eq('id', id))
        .then(removeId)
        .then(MediaVideo.serializer.fromMap);
  }

  Future<List<MediaVideo>> getByUser(String user, {String search: ''}) {
    final b = where.eq('owner', user);
    // TODO also fetch records with write and read access
    // Name search
    if (search != null && search.isNotEmpty) {
      if (!search.contains("^\$")) {
        search = ".*$search.*";
      }
      b.eq("name", {"\$regex": search});
    }
    return col
        .find(b)
        .map(removeId)
        .map(MediaVideo.serializer.fromMap)
        .toList();
  }

  Future<void> save(String id, MediaCreator data) async {
    final m = modify;
    final json = data.toJson();
    for (String key in json.keys) {
      m.set(key, json[key]);
    }
    await col.update(where.eq('id', id), m);
  }

  Future<void> setOwner(String id, String owner) async {
    await col.update(where.eq('id', id), modify.set('owner', owner));
  }

  Future<void> delete(String id) async {
    await col.remove(where.eq('id', id));
  }
}

class MediaFontAccessor {
  Db db;

  MediaFontAccessor(this.db);

  DbCollection get col => db.collection('mfont');

  Future<String> create(MediaFont model) async {
    final id = model.id ?? idGenerator.generateReadable();
    final query = MediaFont.serializer.toMap(model)
      ..addAll({
        "id": id,
      });
    await col.insert(query);
    return id;
  }

  Future<MediaFont> get(String id) {
    return col
        .findOne(where.eq('id', id))
        .then(removeId)
        .then(MediaFont.serializer.fromMap);
  }

  Future<List<MediaFont>> getByUser(String user, {String search: ''}) {
    final b = where.eq('owner', user);
    // TODO also fetch records with write and read access
    // Name search
    if (search != null && search.isNotEmpty) {
      if (!search.contains("^\$")) {
        search = ".*$search.*";
      }
      b.eq("name", {"\$regex": search});
    }
    return col
        .find(b)
        .map(removeId)
        .map(MediaFont.serializer.fromMap)
        .toList();
  }

  Future<void> save(String id, MediaCreator data) async {
    final m = modify;
    final json = data.toJson();
    for (String key in json.keys) {
      m.set(key, json[key]);
    }
    await col.update(where.eq('id', id), m);
  }

  Future<void> setOwner(String id, String owner) async {
    await col.update(where.eq('id', id), modify.set('owner', owner));
  }

  Future<void> delete(String id) async {
    await col.remove(where.eq('id', id));
  }
}
