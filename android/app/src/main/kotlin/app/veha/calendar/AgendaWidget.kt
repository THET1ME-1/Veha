package app.veha.calendar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService

/** Ближайшие дела списком. */
class AgendaWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
    ) {
        for (id in ids) render(context, manager, id)
    }

    companion object {
        fun render(context: Context, manager: AppWidgetManager, id: Int) {
            val snapshot = WidgetData.read(context)
            val views = RemoteViews(context.packageName, R.layout.widget_agenda)

            views.setTextViewText(R.id.widget_title, snapshot.heading)
            views.setTextViewText(R.id.widget_count, snapshot.countText)

            views.setViewVisibility(
                R.id.widget_empty,
                if (snapshot.items.isEmpty()) View.VISIBLE else View.GONE,
            )
            views.setTextViewText(R.id.widget_empty, snapshot.emptyText)

            // Адаптер списка живёт в сервисе: RemoteViews сами по себе список
            // наполнять не умеют.
            val service = Intent(context, AgendaService::class.java)
            service.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
            // Без уникального data система переиспользует фабрику соседнего
            // виджета, и оба показывают одно и то же.
            service.data = Uri.parse(service.toUri(Intent.URI_INTENT_SCHEME))
            views.setRemoteAdapter(R.id.widget_list, service)
            views.setEmptyView(R.id.widget_list, R.id.widget_empty)

            val open = Intent(context, MainActivity::class.java)
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                PendingIntent.FLAG_IMMUTABLE
            views.setPendingIntentTemplate(
                R.id.widget_list,
                PendingIntent.getActivity(context, 0, open, flags),
            )
            views.setOnClickPendingIntent(
                R.id.widget_title,
                PendingIntent.getActivity(context, 0, open, flags),
            )

            manager.updateAppWidget(id, views)
            manager.notifyAppWidgetViewDataChanged(id, R.id.widget_list)
        }
    }
}

/** Компактный: число, день недели и ближайшее дело. */
class TodayWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
    ) {
        for (id in ids) render(context, manager, id)
    }

    companion object {
        fun render(context: Context, manager: AppWidgetManager, id: Int) {
            val snapshot = WidgetData.read(context)
            val views = RemoteViews(context.packageName, R.layout.widget_today)

            views.setTextViewText(R.id.today_day, snapshot.day)
            views.setTextViewText(R.id.today_weekday, snapshot.weekday)

            val next = snapshot.items.firstOrNull { !it.done }
            views.setTextViewText(
                R.id.today_next,
                if (next == null) {
                    snapshot.emptyText
                } else if (next.time.isEmpty()) {
                    next.title
                } else {
                    "${next.time} · ${next.title}"
                },
            )

            val open = Intent(context, MainActivity::class.java)
            views.setOnClickPendingIntent(
                R.id.today_day,
                PendingIntent.getActivity(
                    context,
                    0,
                    open,
                    PendingIntent.FLAG_UPDATE_CURRENT or
                        PendingIntent.FLAG_IMMUTABLE,
                ),
            )

            manager.updateAppWidget(id, views)
        }
    }
}

/** Поставщик строк списка. */
class AgendaService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        AgendaFactory(applicationContext)
}

private class AgendaFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {

    private var items: List<WidgetData.Item> = emptyList()

    override fun onCreate() = Unit

    override fun onDataSetChanged() {
        items = WidgetData.read(context).items
    }

    override fun onDestroy() {
        items = emptyList()
    }

    override fun getCount() = items.size

    override fun getViewAt(position: Int): RemoteViews {
        val item = items[position]
        val views =
            RemoteViews(context.packageName, R.layout.widget_agenda_item)

        views.setTextViewText(R.id.item_time, item.time)
        views.setTextViewText(R.id.item_title, item.title)
        // Кружок один на все строки, цвет ставится фильтром: заводить по
        // ресурсу на каждый календарь нельзя, их заводит человек.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorStateList(
                R.id.item_dot,
                "setImageTintList",
                android.content.res.ColorStateList.valueOf(item.color),
            )
        } else {
            views.setInt(R.id.item_dot, "setColorFilter", item.color)
        }
        // Сделанное гасим прозрачностью: зачёркивание в RemoteViews требует
        // Spannable, а он теряется при передаче между процессами.
        views.setInt(
            R.id.item_title,
            "setTextColor",
            if (item.done) Color.GRAY else context.getColor(R.color.widget_text),
        )

        views.setOnClickFillInIntent(R.id.item_title, Intent())
        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount() = 1

    override fun getItemId(position: Int) = position.toLong()

    override fun hasStableIds() = true
}
