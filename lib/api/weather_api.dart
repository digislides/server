part of 'api.dart';

@GenController(path: '/api/data/weather')
class WeatherRoutes extends Controller {
  @GetJson(path: '/current/:place')
  Future<Weather> getCurrent(Context ctx, String place, Db db) async {
    final accessor = WeatherAccessor(db);
    final data = await accessor.getByName(place);
    if (data == null) {
      ctx.response =
          Response("Weather for place not found in database!", statusCode: 401);
      return null;
    }
    return data;
  }

  @GetJson(path: '/hourly/:place')
  Future<HourlyForecasts> getHourly(Context ctx, String place, Db db) async {
    final accessor = WeatherAccessor(db);
    final data = await accessor.getHourlyByName(place);
    if (data == null) {
      ctx.response =
          Response("Weather for place not found in database!", statusCode: 401);
      return null;
    }
    return data;
  }

  @override
  Future<void> before(Context ctx) async {
    await mgoPool(ctx);
  }
}
