package com.jarvis.jarvis_ai

import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onPostResume() {
        super.onPostResume()
        
        // Request peak refresh rate (120Hz / 90Hz) depending on hardware capabilities
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val currentDisplay = display
            if (currentDisplay != null) {
                val supportedModes = currentDisplay.supportedModes
                var bestMode = currentDisplay.mode
                var highestRate = 60.0f
                for (mode in supportedModes) {
                    if (mode.refreshRate > highestRate) {
                        highestRate = mode.refreshRate
                        bestMode = mode
                    }
                }
                if (highestRate > 60.0f) {
                    val attrs = window.attributes
                    attrs.preferredDisplayModeId = bestMode.modeId
                    window.attributes = attrs
                }
            }
        } else {
            // Fallback for older Android versions
            val attrs = window.attributes
            @Suppress("DEPRECATION")
            attrs.preferredRefreshRate = 120.0f
            window.attributes = attrs
        }
    }
}
