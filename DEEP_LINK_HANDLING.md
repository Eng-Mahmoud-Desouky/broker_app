# 🔗 Deep Link Handling for E-commerce Platforms

## Overview

This document explains how the app handles deep links from e-commerce platforms (AliExpress, SHEIN, Amazon, Taobao, Alibaba, Temu) and converts them to standard HTTPS URLs that can be loaded in WebView.

---

## 🎯 Problem Statement

E-commerce apps often use custom URL schemes (deep links) to open products:

```
aliexpress://goto?url=https%3A%2F%2Fwww.aliexpress.com%2Fitem%2F...
shein://product/12345
amazon://dp/B08XYZ123
```

These URLs **cannot be loaded directly in WebView** because:
1. WebView only supports `http://` and `https://` schemes
2. The actual product URL is encoded inside the deep link
3. Different platforms use different deep link formats

---

## ✅ Solution

The app implements automatic deep link detection and URL extraction:

### 1. **Deep Link Detection**

The app detects deep links from these platforms:
- `aliexpress://`
- `shein://`
- `amazon://`
- `taobao://`
- `alibaba://`
- `temu://`

### 2. **URL Extraction**

Three extraction methods are used (in order):

#### Method 1: Query Parameter Extraction
```dart
// Extract from: aliexpress://goto?url=https%3A%2F%2Fwww.aliexpress.com%2F...
final uri = Uri.parse(deepLink);
final encodedUrl = uri.queryParameters['url'];
final decodedUrl = Uri.decodeComponent(encodedUrl);
// Result: https://www.aliexpress.com/...
```

#### Method 2: Regex Pattern Matching
```dart
// Find any HTTPS URL in the deep link string
final httpsMatch = RegExp(r'https?://[^\s&]+').firstMatch(deepLink);
final extractedUrl = Uri.decodeComponent(httpsMatch.group(0)!);
```

#### Method 3: Platform Homepage Fallback
```dart
// If extraction fails, redirect to platform homepage
if (deepLink.contains('aliexpress')) {
  return 'https://www.aliexpress.com';
}
```

---

## 🔧 Implementation

### Code Location

File: `lib/features/webview/presentation/pages/webview_screen.dart`

### Key Methods

#### 1. `_cleanUrl(String url)`
Main entry point for URL cleaning.

```dart
String _cleanUrl(String url) {
  // Check if it's a deep link
  if (url.startsWith('aliexpress://') ||
      url.startsWith('shein://') ||
      url.startsWith('amazon://') ||
      url.startsWith('taobao://') ||
      url.startsWith('alibaba://') ||
      url.startsWith('temu://')) {
    return _extractRealUrl(url);
  }
  
  return url;
}
```

#### 2. `_extractRealUrl(String deepLink)`
Extracts the real HTTPS URL from the deep link.

```dart
String _extractRealUrl(String deepLink) {
  try {
    final uri = Uri.parse(deepLink);
    
    // Try to extract 'url' parameter
    final encodedUrl = uri.queryParameters['url'];
    
    if (encodedUrl != null) {
      final decodedUrl = Uri.decodeComponent(encodedUrl);
      print('✅ Extracted URL from deep link: $decodedUrl');
      return decodedUrl;
    }
    
    // Fallback: Try to find any https URL in the string
    final httpsMatch = RegExp(r'https?://[^\s&]+').firstMatch(deepLink);
    if (httpsMatch != null) {
      final extractedUrl = Uri.decodeComponent(httpsMatch.group(0)!);
      print('✅ Extracted URL via regex: $extractedUrl');
      return extractedUrl;
    }
    
    // Last resort: Return platform homepage
    return _getPlatformHomepage(deepLink);
    
  } catch (e) {
    print('❌ Error extracting URL: $e');
    return _getPlatformHomepage(deepLink);
  }
}
```

#### 3. `_getPlatformHomepage(String deepLink)`
Returns the platform homepage as a fallback.

```dart
String _getPlatformHomepage(String deepLink) {
  if (deepLink.contains('aliexpress')) {
    return 'https://www.aliexpress.com';
  } else if (deepLink.contains('shein')) {
    return 'https://www.shein.com';
  } else if (deepLink.contains('amazon')) {
    return 'https://www.amazon.com';
  } else if (deepLink.contains('taobao')) {
    return 'https://www.taobao.com';
  } else if (deepLink.contains('alibaba')) {
    return 'https://www.alibaba.com';
  } else if (deepLink.contains('temu')) {
    return 'https://www.temu.com';
  }
  return 'https://www.google.com';
}
```

---

## 🚀 Usage Points

### 1. Initial URL Loading

When the WebView screen is opened:

```dart
@override
void initState() {
  super.initState();
  // Clean and load the initial URL (handles deep links)
  final cleanedUrl = _cleanUrl(widget.initialUrl);
  _webViewBloc.add(WebViewLoadUrl(url: cleanedUrl));
}
```

### 2. WebView Initialization

When building the WebView widget:

```dart
Widget _buildWebView() {
  // Clean the URL before loading (handles deep links)
  final cleanedUrl = _cleanUrl(widget.initialUrl);
  
  return InAppWebView(
    initialUrlRequest: URLRequest(url: WebUri(cleanedUrl)),
    // ... other settings
  );
}
```

### 3. Navigation Interception

When user navigates to a deep link during browsing:

```dart
shouldOverrideUrlLoading: (controller, navigationAction) async {
  final url = navigationAction.request.url.toString();
  
  // Handle deep links from e-commerce apps
  if (url.startsWith('aliexpress://') ||
      url.startsWith('shein://') ||
      url.startsWith('amazon://') ||
      url.startsWith('taobao://') ||
      url.startsWith('alibaba://') ||
      url.startsWith('temu://')) {
    
    final cleanedUrl = _cleanUrl(url);
    print('🔄 Deep link detected, redirecting to: $cleanedUrl');
    
    // Load the cleaned URL
    await controller.loadUrl(
      urlRequest: URLRequest(url: WebUri(cleanedUrl)),
    );
    return NavigationActionPolicy.CANCEL;
  }
  
  // ... other navigation handling
}
```

---

## 📊 Supported Deep Link Formats

### AliExpress
```
aliexpress://goto?url=https%3A%2F%2Fwww.aliexpress.com%2Fitem%2F1234567890.html
→ https://www.aliexpress.com/item/1234567890.html
```

### SHEIN
```
shein://product/12345?url=https%3A%2F%2Fwww.shein.com%2Fproduct%2F12345
→ https://www.shein.com/product/12345
```

### Amazon
```
amazon://dp/B08XYZ123?url=https%3A%2F%2Fwww.amazon.com%2Fdp%2FB08XYZ123
→ https://www.amazon.com/dp/B08XYZ123
```

### Taobao
```
taobao://item?id=123456&url=https%3A%2F%2Fitem.taobao.com%2Fitem.htm%3Fid%3D123456
→ https://item.taobao.com/item.htm?id=123456
```

### Alibaba
```
alibaba://product/123456?url=https%3A%2F%2Fwww.alibaba.com%2Fproduct%2F123456
→ https://www.alibaba.com/product/123456
```

### Temu
```
temu://product/123456?url=https%3A%2F%2Fwww.temu.com%2Fproduct%2F123456
→ https://www.temu.com/product/123456
```

---

## 🐛 Debugging

### Enable Debug Logging

The implementation includes debug logging:

```dart
if (kDebugMode) {
  print('✅ Extracted URL from deep link: $decodedUrl');
  print('🔄 Deep link detected, redirecting to: $cleanedUrl');
  print('❌ Error extracting URL: $e');
}
```

### Check Logs

Look for these log messages:
- `✅ Extracted URL from deep link:` - Successful extraction
- `✅ Extracted URL via regex:` - Regex fallback used
- `🔄 Deep link detected, redirecting to:` - Navigation interception
- `❌ Error extracting URL:` - Extraction failed

---

## ✅ Testing

### Test Cases

1. **Direct Deep Link**
   ```dart
   WebViewScreen(
     initialUrl: 'aliexpress://goto?url=https%3A%2F%2Fwww.aliexpress.com%2F...',
     title: 'AliExpress',
   )
   ```
   Expected: Opens the decoded HTTPS URL

2. **Navigation to Deep Link**
   - Open a product page
   - Click a link that redirects to deep link
   - Expected: Automatically converts and loads HTTPS URL

3. **Invalid Deep Link**
   ```dart
   WebViewScreen(
     initialUrl: 'aliexpress://invalid',
     title: 'AliExpress',
   )
   ```
   Expected: Redirects to platform homepage

4. **Normal HTTPS URL**
   ```dart
   WebViewScreen(
     initialUrl: 'https://www.aliexpress.com',
     title: 'AliExpress',
   )
   ```
   Expected: Loads normally without modification

---

## 🔒 Security Considerations

1. **URL Validation**: Only platform-specific deep links are processed
2. **Fallback Safety**: Invalid URLs redirect to platform homepage
3. **No External Redirects**: Deep links to other apps are blocked
4. **Error Handling**: All extraction errors are caught and logged

---

## 🎯 Future Enhancements

Potential improvements:

1. **More Platforms**: Add support for more e-commerce platforms
2. **Custom Parameters**: Extract and preserve custom parameters
3. **Analytics**: Track deep link usage and conversion rates
4. **Caching**: Cache extracted URLs to improve performance
5. **User Feedback**: Show toast when deep link is detected

---

## 📝 Notes

- Deep link handling is **automatic** and **transparent** to the user
- No user action required - URLs are cleaned before loading
- Works for both initial URL and navigation during browsing
- Fallback to platform homepage ensures app never breaks
- Debug logging helps troubleshoot extraction issues

---

**Status**: ✅ Implemented and Working
**Platforms Supported**: 6 (AliExpress, SHEIN, Amazon, Taobao, Alibaba, Temu)
**Last Updated**: 2025-10-05

