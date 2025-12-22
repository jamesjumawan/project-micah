// Use a conditional import so the web implementation (which uses web-only
// libraries) is only included for web targets. Non-web targets get a small
// stub widget.
export 'three_d_viewer_stub.dart'
    if (dart.library.html) 'three_d_viewer_web.dart';

// The real `ThreeDViewer` widget is provided by the conditionally exported
// file. This file exists only to select the correct implementation at
// compile-time.
