package com.example.sisonke

import io.flutter.embedding.android.FlutterFragmentActivity
import android.os.Bundle
import android.view.WindowManager

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Block screenshots and hide app previews in the Recents menu for deep privacy
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
