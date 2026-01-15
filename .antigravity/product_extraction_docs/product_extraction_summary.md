# ملخص سريع: كيف يعمل نظام استخراج بيانات المنتجات؟

## الفكرة الأساسية
التطبيق يفتح مواقع التسوق الإلكترونية (مثل Amazon وAliExpress) داخل متصفح مدمج (WebView)، ثم يحقن كود JavaScript في الصفحة لاستخراج بيانات المنتج تلقائياً وإضافته للسلة.

---

## الخطوات الخمس الرئيسية

### 1️⃣ فتح الموقع
```
المستخدم يضغط على منصة → التطبيق يفتح WebView
```

### 2️⃣ حقن JavaScript
```
بعد تحميل الصفحة → حقن كود JavaScript + إضافة زر "إضافة للسلة"
```

### 3️⃣ استخراج البيانات
```javascript
// عند الضغط على الزر
const title = document.querySelector('#productTitle').innerText;
const price = document.querySelector('.a-price').innerText;
const image = document.querySelector('#landingImage').src;
```

### 4️⃣ إرسال البيانات لـ Flutter
```javascript
// عبر JavaScript Channel
window.flutter_inappwebview.callHandler('FlutterCartChannel', {
  title: "اسم المنتج",
  price: "$49.99",
  image: "https://...",
  url: "https://..."
});
```

### 5️⃣ حفظ في السلة
```dart
// في Flutter
_cartBloc.add(CartAddItem(
  productName: productData['title'],
  price: productData['price'],
  imageUrl: productData['image'],
));
```

---

## المكونات الأساسية

| المكون | الوظيفة |
|--------|---------|
| **WebView** | عرض المواقع داخل التطبيق |
| **Platform Selectors** | قواعد استخراج البيانات لكل موقع |
| **JavaScript Injection** | حقن كود لاستخراج البيانات |
| **JavaScript Channel** | قناة اتصال بين JavaScript و Flutter |
| **Cart Bloc** | إدارة السلة وحفظ البيانات |

---

## CSS Selectors - أمثلة

### Amazon:
```dart
'title': '#productTitle'
'price': '.a-price .a-offscreen'
'image': '#landingImage'
```

### AliExpress:
```dart
'title': 'h1[data-pl="product-title"]'
'price': 'span[class*="price-default--current"]'
'image': 'img[class*="magnifier-image"]'
```

### SHEIN:
```dart
'title': '.product-intro__head-name'
'price': '.product-intro__price'
'image': '.product-intro__main-img img'
```

---

## البيانات المستخرجة

```json
{
  "title": "اسم المنتج",
  "price": "السعر",
  "image": "الصورة الرئيسية",
  "images": ["صورة1", "صورة2"],
  "rating": "التقييم",
  "url": "رابط المنتج",
  "platform": "amazon",
  "description": "الوصف"
}
```

---

## التقنيات المتقدمة

✅ **Fallback Strategy**: إذا فشل selector، يجرب آخر
✅ **MutationObserver**: ينتظر تحميل العناصر الديناميكية
✅ **User-Agent Spoofing**: يخفي هوية WebView
✅ **Cookie Management**: للمواقع التي تحتاج إعدادات خاصة
✅ **Ad Blocking**: حظر الإعلانات لأداء أفضل

---

## المميزات

- 🎯 **استخراج تلقائي بالكامل** - بدون نسخ/لصق يدوي
- 🌍 **دعم منصات متعددة** - Amazon, AliExpress, SHEIN, Taobao, Alibaba
- 📦 **بيانات شاملة** - العنوان، السعر، الصور، التقييم
- ⚡ **أداء سريع** - حظر الإعلانات والتتبع
- 🛡️ **استراتيجية احتياطية** - إذا فشلت طريقة، تجرب أخرى

---

## التحديات والحلول

| التحدي | الحل |
|--------|------|
| المواقع الديناميكية | استخدام `waitForElement()` و `MutationObserver` |
| CSS Selectors تتغير | قائمة احتياطية طويلة من Selectors |
| كشف WebView | User-Agent مخصص لكل منصة |
| المواقع الصينية | اعتراض redirects + إعدادات cookies خاصة |

---

## الخلاصة في سطر واحد

**WebView يفتح الموقع → JavaScript يستخرج البيانات → JavaScript Channel ينقلها لـ Flutter → Cart Bloc يحفظها → المستخدم يراها في السلة!**

---

## للمزيد من التفاصيل

راجع الوثيقة الكاملة: [`product_extraction_explanation.md`](./product_extraction_explanation.md)
