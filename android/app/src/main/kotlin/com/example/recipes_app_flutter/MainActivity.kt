package com.example.recipes_app_flutter

import android.os.Bundle
import android.os.PersistableBundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)
        setContentView(R.layout.activity_splash)
    }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        /*val manager = fragmentManager
        val transaction = manager.beginTransaction()
        transaction.add(R.id.container, MyFlutterFragment())
        transaction.addToBackStack(null)
        transaction.commit()*/
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}
