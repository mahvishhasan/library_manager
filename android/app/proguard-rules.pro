# --- keep ZXing for barcode_scan2 -------------
-keep class com.journeyapps.barcodescanner.** { *; }
-keep class com.google.zxing.**              { *; }
-keepattributes *Annotation*
