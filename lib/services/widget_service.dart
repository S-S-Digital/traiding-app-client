import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const _appGroupId = 'group.com.aspiro.trade';
  static const _iosWidgetName = 'AspiroSignalWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> pushSignal({
    required String symbol,
    required String direction,
    required double price,
    required double tp,
    required double sl,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('signal_symbol', symbol);
      await HomeWidget.saveWidgetData<String>(
        'signal_direction',
        direction.toUpperCase(),
      );
      await HomeWidget.saveWidgetData<double>('signal_price', price);
      await HomeWidget.saveWidgetData<double>('signal_tp', tp);
      await HomeWidget.saveWidgetData<double>('signal_sl', sl);
      await HomeWidget.saveWidgetData<double>(
        'signal_ts',
        DateTime.now().millisecondsSinceEpoch / 1000,
      );
      await HomeWidget.updateWidget(
        name: _iosWidgetName,
        iOSName: _iosWidgetName,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WidgetService.pushSignal failed: $e');
      }
    }
  }
}
