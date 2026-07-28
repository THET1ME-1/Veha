package app.veha.calendar

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        // Виджеты не считают календарь сами: развёртка повторений, наследование
        // цвета и выбор видимых календарей живут в Dart. Оттуда приходит
        // готовый JSON — уже с переведёнными подписями.
        MethodChannel(engine.dartExecutor.binaryMessenger, "veha/widgets")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "refresh" -> {
                        WidgetData.write(
                            applicationContext,
                            call.arguments as String,
                        )
                        refreshWidgets()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun refreshWidgets() {
        val manager = AppWidgetManager.getInstance(applicationContext)

        for (id in manager.getAppWidgetIds(
            ComponentName(applicationContext, AgendaWidget::class.java),
        )) {
            AgendaWidget.render(applicationContext, manager, id)
        }
        for (id in manager.getAppWidgetIds(
            ComponentName(applicationContext, TodayWidget::class.java),
        )) {
            TodayWidget.render(applicationContext, manager, id)
        }
    }
}
