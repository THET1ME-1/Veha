package app.veha.calendar

import android.content.Context
import org.json.JSONObject
import java.io.File

/**
 * Данные виджетов.
 *
 * Flutter кладёт готовый JSON в файл, Kotlin его читает. Считать календарь на
 * стороне виджета невозможно: развёртка повторений, наследование цвета и
 * выбор видимых календарей живут в Dart, и второй счётчик разошёлся бы с
 * первым на первом же переводе часов.
 *
 * Всё, что виден человеку, приходит уже переведённым: подписи собирает Dart,
 * который знает выбранный язык.
 */
object WidgetData {
    private const val FILE = "widget_data.json"

    data class Item(
        val title: String,
        val time: String,
        val color: Int,
        val done: Boolean,
    )

    data class Snapshot(
        val heading: String,
        val day: String,
        val weekday: String,
        val emptyText: String,
        val countText: String,
        val items: List<Item>,
    )

    fun write(context: Context, json: String) {
        File(context.filesDir, FILE).writeText(json)
    }

    fun read(context: Context): Snapshot {
        val file = File(context.filesDir, FILE)
        if (!file.exists()) return empty()

        return try {
            val root = JSONObject(file.readText())
            val array = root.optJSONArray("items")
            val items = buildList {
                for (i in 0 until (array?.length() ?: 0)) {
                    val row = array!!.getJSONObject(i)
                    add(
                        Item(
                            title = row.optString("title"),
                            time = row.optString("time"),
                            color = row.optLong("color", 0xFF41CCB5).toInt(),
                            done = row.optBoolean("done", false),
                        ),
                    )
                }
            }
            Snapshot(
                heading = root.optString("heading"),
                day = root.optString("day"),
                weekday = root.optString("weekday"),
                emptyText = root.optString("empty"),
                countText = root.optString("count"),
                items = items,
            )
        } catch (e: Exception) {
            // Битый файл не должен ронять рабочий стол: виджет покажет пустоту,
            // а следующий запуск приложения перепишет данные.
            empty()
        }
    }

    private fun empty() = Snapshot("Veha", "", "", "", "", emptyList())
}
