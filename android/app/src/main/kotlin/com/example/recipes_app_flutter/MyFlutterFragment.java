package com.example.recipes_app_flutter;

import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.android.SplashScreen;

public class MyFlutterFragment extends FlutterFragment {
    @Override
    public SplashScreen provideSplashScreen() {
        return new SimpleSplashScreen();
    }
}
