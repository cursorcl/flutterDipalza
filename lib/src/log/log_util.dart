

import 'log_model.dart';

LogModel creaLogInfo(String clase, String metodo, String info) {
  return LogModel(
      id: DateTime.now().toUtc().microsecondsSinceEpoch,
      tipo: 'INFO',
      log:
          '[${DateTime.now().toLocal().toString()}] [INFO] [$clase] [$metodo] [$info]');
}

LogModel creaLogError(String clase, String metodo, String info) {
  return LogModel(
      id: DateTime.now().toUtc().microsecondsSinceEpoch,
      tipo: 'ERROR',
      log:
          '[${DateTime.now().toLocal().toString()}] [ERROR] [$clase] [$metodo] [$info]');
}
