part of 'db.dart';

class WeatherAccessor {
  final Db db;

  WeatherAccessor(this.db);

  Future<Weather> getById(int id) {
    return db
        .collection('data_weath_cur')
        .findOne(where.eq('id', id))
        .then(Weather.serializer.fromMap);
  }

  Future<Weather> getByName(String name) {
    return db
        .collection('data_weath_cur')
        .findOne(where.eq("name", name))
        .then(Weather.serializer.fromMap);
  }

  Future<HourlyForecasts> getHourlyById(int id) {
    return db
        .collection('data_weath_hour')
        .findOne(where.eq('id', id))
        .then(HourlyForecasts.serializer.fromMap);
  }

  Future<HourlyForecasts> getHourlyByName(String name) {
    return db
        .collection('data_weath_hour')
        .findOne(where.eq("name", name))
        .then(HourlyForecasts.serializer.fromMap);
  }

  /* TODO
  Future<Weather> getDailyById(String id) {
    return db.collection('data_weath_daily')
        .findOne(where.eq('id', id))
        .then(Weather.serializer.fromMap);
  }

  Future<Weather> getDailyByName(String name) {
    return db.collection('data_weath_daily')
        .findOne(where.eq("email", name))
        .then(Weather.serializer.fromMap);
  }
  */
}
