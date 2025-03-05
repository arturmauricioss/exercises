// ========================
// Estrutura de arquivos:
// ========================
// - MainActivity.kt
// - CounterViewModel.kt
// - Counter.kt (modelo de dados)
// - CounterAdapter.kt
// - CounterWidget.kt
// - activity_main.xml
// - item_counter.xml
// - widget_counter.xml

// ========================
// Counter.kt - Modelo de dados
// ========================
package com.example.dailycounter

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.time.LocalDate

@Entity(tableName = "counters")
data class Counter(
@PrimaryKey(autoGenerate = true)
val id: Long = 0,
val name: String,
var isCompleted: Boolean = false,
var streak: Int = 0,
var lastCompletedDate: LocalDate? = null
) {
fun completeForToday() {
val today = LocalDate.now()

        if (isCompleted) {
            // Já completou hoje, então desmarcando
            isCompleted = false
            // Não alteramos o streak aqui, pois ainda tem o resto do dia para completar
        } else {
            // Marcando como completo
            isCompleted = true
            lastCompletedDate = today

            // Verificamos se é um novo dia após o último completado
            val yesterday = today.minusDays(1)
            if (lastCompletedDate == yesterday || lastCompletedDate == today) {
                streak++
            } else if (lastCompletedDate != today) {
                // Se não foi completado ontem (nem hoje), resetamos o streak
                streak = 1 // Começamos um novo streak
            }
        }
    }

    fun checkAndResetDaily() {
        val today = LocalDate.now()
        val yesterday = today.minusDays(1)

        if (lastCompletedDate == null || lastCompletedDate!!.isBefore(yesterday)) {
            // Não foi completado ontem, perde todas as ofensivas
            streak = 0
        }

        if (lastCompletedDate == null || !lastCompletedDate!!.isEqual(today)) {
            // Reseta para "não feito" se não foi completado hoje
            isCompleted = false
        }
    }

}

// ========================
// CounterDao.kt - Interface para acesso ao banco de dados
// ========================
package com.example.dailycounter

import androidx.lifecycle.LiveData
import androidx.room.\*

@Dao
interface CounterDao {
@Query("SELECT \* FROM counters")
fun getAllCounters(): LiveData<List<Counter>>

    @Query("SELECT * FROM counters WHERE id = :id")
    fun getCounterById(id: Long): LiveData<Counter>

    @Insert
    suspend fun insert(counter: Counter): Long

    @Update
    suspend fun update(counter: Counter)

    @Delete
    suspend fun delete(counter: Counter)

}

// ========================
// AppDatabase.kt - Banco de dados Room
// ========================
package com.example.dailycounter

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

@Database(entities = [Counter::class], version = 1, exportSchema = false)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
abstract fun counterDao(): CounterDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "counter_database"
                )
                .fallbackToDestructiveMigration()
                .build()
                INSTANCE = instance
                instance
            }
        }
    }

}

// ========================
// Converters.kt - Conversores para tipos de dados complexos
// ========================
package com.example.dailycounter

import androidx.room.TypeConverter
import java.time.LocalDate

class Converters {
@TypeConverter
fun fromTimestamp(value: Long?): LocalDate? {
return value?.let { LocalDate.ofEpochDay(it) }
}

    @TypeConverter
    fun dateToTimestamp(date: LocalDate?): Long? {
        return date?.toEpochDay()
    }

}

// ========================
// CounterRepository.kt - Repositório para gerenciar dados
// ========================
package com.example.dailycounter

import androidx.lifecycle.LiveData

class CounterRepository(private val counterDao: CounterDao) {
val allCounters: LiveData<List<Counter>> = counterDao.getAllCounters()

    suspend fun insert(counter: Counter): Long {
        return counterDao.insert(counter)
    }

    suspend fun update(counter: Counter) {
        counterDao.update(counter)
    }

    suspend fun delete(counter: Counter) {
        counterDao.delete(counter)
    }

    fun getCounterById(id: Long): LiveData<Counter> {
        return counterDao.getCounterById(id)
    }

}

// ========================
// CounterViewModel.kt - ViewModel
// ========================
package com.example.dailycounter

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.LocalDate

class CounterViewModel(application: Application) : AndroidViewModel(application) {
private val repository: CounterRepository
val allCounters: LiveData<List<Counter>>

    init {
        val counterDao = AppDatabase.getDatabase(application).counterDao()
        repository = CounterRepository(counterDao)
        allCounters = repository.allCounters

        // Verificar e resetar contadores diariamente
        checkAndResetCounters()
    }

    fun insert(counter: Counter) = viewModelScope.launch(Dispatchers.IO) {
        repository.insert(counter)
    }

    fun update(counter: Counter) = viewModelScope.launch(Dispatchers.IO) {
        repository.update(counter)
    }

    fun delete(counter: Counter) = viewModelScope.launch(Dispatchers.IO) {
        repository.delete(counter)
    }

    fun toggleCounterStatus(counter: Counter) = viewModelScope.launch(Dispatchers.IO) {
        counter.completeForToday()
        repository.update(counter)
    }

    private fun checkAndResetCounters() = viewModelScope.launch(Dispatchers.IO) {
        val counters = allCounters.value ?: return@launch
        for (counter in counters) {
            counter.checkAndResetDaily()
            repository.update(counter)
        }
    }

    fun getCounterById(id: Long): LiveData<Counter> {
        return repository.getCounterById(id)
    }

}

// ========================
// MainActivity.kt - Activity principal
// ========================
package com.example.dailycounter

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import java.time.LocalDate
import java.util.\*

class MainActivity : AppCompatActivity() {
private lateinit var counterViewModel: CounterViewModel
private lateinit var adapter: CounterAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val recyclerView = findViewById<RecyclerView>(R.id.recyclerView)
        adapter = CounterAdapter { counter ->
            counterViewModel.toggleCounterStatus(counter)
            updateWidgets()
        }
        recyclerView.adapter = adapter
        recyclerView.layoutManager = LinearLayoutManager(this)

        counterViewModel = ViewModelProvider(this).get(CounterViewModel::class.java)
        counterViewModel.allCounters.observe(this) { counters ->
            adapter.submitList(counters)
        }

        findViewById<FloatingActionButton>(R.id.fab).setOnClickListener {
            showAddCounterDialog()
        }

        // Configurar alarme para verificar e resetar contadores à meia-noite
        setupMidnightAlarm()
    }

    private fun showAddCounterDialog() {
        val dialogView = layoutInflater.inflate(R.layout.dialog_add_counter, null)
        val editTextName = dialogView.findViewById<EditText>(R.id.editTextCounterName)

        AlertDialog.Builder(this)
            .setTitle("Adicionar Novo Contador")
            .setView(dialogView)
            .setPositiveButton("Adicionar") { _, _ ->
                val name = editTextName.text.toString().trim()
                if (name.isNotEmpty()) {
                    val counter = Counter(name = name)
                    counterViewModel.insert(counter)
                    updateWidgets()
                } else {
                    Toast.makeText(this, "Nome não pode ser vazio", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancelar", null)
            .show()
    }

    private fun setupMidnightAlarm() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, DailyResetReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Configurar para executar à meia-noite
        val calendar = Calendar.getInstance().apply {
            timeInMillis = System.currentTimeMillis()
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            add(Calendar.DAY_OF_YEAR, 1)
        }

        alarmManager.setRepeating(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            AlarmManager.INTERVAL_DAY,
            pendingIntent
        )
    }

    private fun updateWidgets() {
        val intent = Intent(this, CounterWidget::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        val ids = AppWidgetManager.getInstance(application)
            .getAppWidgetIds(ComponentName(application, CounterWidget::class.java))
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        sendBroadcast(intent)
    }

}

// ========================
// CounterAdapter.kt - Adaptador para RecyclerView
// ========================
package com.example.dailycounter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView

class CounterAdapter(private val onItemClick: (Counter) -> Unit) :
ListAdapter<Counter, CounterAdapter.CounterViewHolder>(COUNTER_COMPARATOR) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CounterViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_counter, parent, false)
        return CounterViewHolder(view)
    }

    override fun onBindViewHolder(holder: CounterViewHolder, position: Int) {
        val current = getItem(position)
        holder.bind(current)
    }

    inner class CounterViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val nameTextView: TextView = itemView.findViewById(R.id.textViewName)
        private val statusImageView: ImageView = itemView.findViewById(R.id.imageViewStatus)
        private val streakTextView: TextView = itemView.findViewById(R.id.textViewStreak)

        init {
            itemView.setOnClickListener {
                val position = adapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onItemClick(getItem(position))
                }
            }
        }

        fun bind(counter: Counter) {
            nameTextView.text = counter.name
            streakTextView.text = "${counter.streak} dias"

            statusImageView.setImageResource(
                if (counter.isCompleted) R.drawable.ic_check_circle
                else R.drawable.ic_unchecked_circle
            )
        }
    }

    companion object {
        private val COUNTER_COMPARATOR = object : DiffUtil.ItemCallback<Counter>() {
            override fun areItemsTheSame(oldItem: Counter, newItem: Counter): Boolean {
                return oldItem.id == newItem.id
            }

            override fun areContentsTheSame(oldItem: Counter, newItem: Counter): Boolean {
                return oldItem.name == newItem.name &&
                       oldItem.isCompleted == newItem.isCompleted &&
                       oldItem.streak == newItem.streak
            }
        }
    }

}

// ========================
// DailyResetReceiver.kt - Receiver para resetar contadores diariamente
// ========================
package com.example.dailycounter

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class DailyResetReceiver : BroadcastReceiver() {
override fun onReceive(context: Context, intent: Intent) {
val db = AppDatabase.getDatabase(context)
val dao = db.counterDao()

        CoroutineScope(Dispatchers.IO).launch {
            val counters = dao.getAllCounters().value ?: return@launch

            for (counter in counters) {
                counter.checkAndResetDaily()
                dao.update(counter)
            }

            // Atualizar widgets
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, CounterWidget::class.java)
            )

            val updateIntent = Intent(context, CounterWidget::class.java)
            updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
            context.sendBroadcast(updateIntent)
        }
    }

}

// ========================
// CounterWidget.kt - Widget para o app
// ========================
package com.example.dailycounter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class CounterWidget : AppWidgetProvider() {
companion object {
const val ACTION_TOGGLE_COUNTER = "ACTION_TOGGLE_COUNTER"
const val EXTRA_COUNTER_ID = "EXTRA_COUNTER_ID"
}

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.action == ACTION_TOGGLE_COUNTER) {
            val counterId = intent.getLongExtra(EXTRA_COUNTER_ID, -1)
            if (counterId != -1L) {
                CoroutineScope(Dispatchers.IO).launch {
                    val db = AppDatabase.getDatabase(context)
                    val dao = db.counterDao()

                    val counter = dao.getCounterById(counterId).value ?: return@launch
                    counter.completeForToday()
                    dao.update(counter)

                    // Atualizar widgets
                    val appWidgetManager = AppWidgetManager.getInstance(context)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(
                        ComponentName(context, CounterWidget::class.java)
                    )

                    withContext(Dispatchers.Main) {
                        onUpdate(context, appWidgetManager, appWidgetIds)
                    }
                }
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            val db = AppDatabase.getDatabase(context)
            val dao = db.counterDao()

            // Pegamos o primeiro contador para o widget (por simplicidade, poderia ser configurável)
            val counters = dao.getAllCounters().value ?: emptyList()
            val counter = if (counters.isNotEmpty()) counters[0] else null

            val views = RemoteViews(context.packageName, R.layout.widget_counter)

            if (counter != null) {
                views.setTextViewText(R.id.widgetTextViewName, counter.name)
                views.setTextViewText(R.id.widgetTextViewStreak, "${counter.streak} dias")

                views.setImageViewResource(
                    R.id.widgetImageViewStatus,
                    if (counter.isCompleted) R.drawable.ic_check_circle
                    else R.drawable.ic_unchecked_circle
                )

                // Configurar o intent para alternar o status do contador
                val toggleIntent = Intent(context, CounterWidget::class.java)
                toggleIntent.action = ACTION_TOGGLE_COUNTER
                toggleIntent.putExtra(EXTRA_COUNTER_ID, counter.id)

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    appWidgetId,
                    toggleIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                views.setOnClickPendingIntent(R.id.widgetContainer, pendingIntent)
            } else {
                views.setTextViewText(R.id.widgetTextViewName, "Nenhum contador")
                views.setTextViewText(R.id.widgetTextViewStreak, "0 dias")
                views.setImageViewResource(R.id.widgetImageViewStatus, R.drawable.ic_unchecked_circle)
            }

            withContext(Dispatchers.Main) {
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }

}

// ========================
// layout/activity_main.xml
// ========================

<?xml version="1.0" encoding="utf-8"?>

<androidx.constraintlayout.widget.ConstraintLayout
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:app="http://schemas.android.com/apk/res-auto"
xmlns:tools="http://schemas.android.com/tools"
android:layout_width="match_parent"
android:layout_height="match_parent"
tools:context=".MainActivity">

    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/recyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

    <com.google.android.material.floatingactionbutton.FloatingActionButton
        android:id="@+id/fab"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_margin="16dp"
        android:src="@drawable/ic_add"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>

// ========================
// layout/item_counter.xml
// ========================

<?xml version="1.0" encoding="utf-8"?>

<androidx.cardview.widget.CardView
xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:app="http://schemas.android.com/apk/res-auto"
android:layout_width="match_parent"
android:layout_height="wrap_content"
android:layout_margin="8dp"
app:cardCornerRadius="8dp"
app:cardElevation="4dp">

    <androidx.constraintlayout.widget.ConstraintLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:padding="16dp">

        <TextView
            android:id="@+id/textViewName"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:textSize="18sp"
            android:textStyle="bold"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintEnd_toStartOf="@+id/imageViewStatus"
            android:layout_marginEnd="16dp" />

        <TextView
            android:id="@+id/textViewStreak"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:textSize="14sp"
            app:layout_constraintStart_toStartOf="parent"
            app:layout_constraintTop_toBottomOf="@+id/textViewName"
            app:layout_constraintEnd_toStartOf="@+id/imageViewStatus"
            android:layout_marginTop="4dp"
            android:layout_marginEnd="16dp" />

        <ImageView
            android:id="@+id/imageViewStatus"
            android:layout_width="40dp"
            android:layout_height="40dp"
            app:layout_constraintEnd_toEndOf="parent"
            app:layout_constraintTop_toTopOf="parent"
            app:layout_constraintBottom_toBottomOf="parent" />

    </androidx.constraintlayout.widget.ConstraintLayout>

</androidx.cardview.widget.CardView>

// ========================
// layout/widget_counter.xml
// ========================

<?xml version="1.0" encoding="utf-8"?>

<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/widgetContainer"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="horizontal"
    android:padding="8dp"
    android:background="@drawable/widget_background">

    <LinearLayout
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:orientation="vertical"
        android:layout_gravity="center_vertical">

        <TextView
            android:id="@+id/widgetTextViewName"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="14sp"
            android:textStyle="bold"
            android:textColor="#FFFFFF" />

        <TextView
            android:id="@+id/widgetTextViewStreak"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textSize="12sp"
            android:textColor="#EEEEEE" />

    </LinearLayout>

    <ImageView
        android:id="@+id/widgetImageViewStatus"
        android:layout_width="30dp"
        android:layout_height="30dp"
        android:layout_gravity="center_vertical" />

</LinearLayout>

// ========================
// layout/dialog_add_counter.xml
// ========================

<?xml version="1.0" encoding="utf-8"?>

<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="vertical"
    android:padding="16dp">

    <EditText
        android:id="@+id/editTextCounterName"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:hint="Nome do contador"
        android:inputType="text" />

</LinearLayout>

// ========================
// drawable/widget_background.xml
// ========================

<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#424242" />
    <corners android:radius="8dp" />
</shape>

// ========================
// drawable/ic_check_circle.xml
// ========================
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="#4CAF50">
<path
        android:fillColor="@android:color/white"
        android:pathData="M12,2C6.48,2 2,6.48 2,12s4.48,10 10,10 10,-4.48 10,-10S17.52,2 12,2zM10,17l-5,-5 1.41,-1.41L10,14.17l7.59,-7.59L19,8l-9,9z"/>
</vector>

// ========================
// drawable/ic_unchecked_circle.xml
// ========================
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="#9E9E9E">
<path
        android:fillColor="@android:color/white"
        android:pathData="M12,2C6.48,2 2,6.48 2,12s4.48,10 10,10 10,-4.48 10,-10S17.52,2 12,2zM12,20c-4.42,0 -8,-3.58 -8,-8s3.58,-8 8,-8 8,3.58 8,8 -3.58,8 -8,8z"/>
</vector>

// ========================
// drawable/ic_add.xml
// ========================
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="#FFFFFF">
<path
        android:fillColor="@android:color/white"
        android:pathData="M19,13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
</vector>

// ========================
// AndroidManifest.xml (parcial)
// ========================
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.dailycounter">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.DailyCounter">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <receiver
            android:name=".CounterWidget"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
                <action android:name="ACTION_TOGGLE_COUNTER" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/counter_widget_info" />
        </receiver>

        <receiver
            android:name=".DailyResetReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>

    </application>

</manifest>

// ========================
// xml/counter_widget_info.xml
// ========================

<?xml version="1.0" encoding="utf-8"?>

<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/widget_counter"
    android:minWidth="180dp"
    android:minHeight="40dp"
    android:previewImage="@drawable/widget_preview"
    android:resizeMode="horizontal|vertical"
    android:updatePeriodMillis="86400000"
    android:widgetCategory="home_screen">
</appwidget-provider>

dependencias
// Room
implementation "androidx.room:room-runtime:2.5.0"
implementation "androidx.room:room-ktx:2.5.0"
kapt "androidx.room:room-compiler:2.5.0"

// ViewModel e LiveData
implementation "androidx.lifecycle:lifecycle-viewmodel-ktx:2.5.1"
implementation "androidx.lifecycle:lifecycle-livedata-ktx:2.5.1"

// Material Design
implementation "com.google.android.material:material:1.8.0"

// Coroutines
implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4"
