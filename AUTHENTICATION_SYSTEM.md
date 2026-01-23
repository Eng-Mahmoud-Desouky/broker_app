# نظام تسجيل الدخول - التوثيق الكامل

## 📱 نظرة عامة

نظام تسجيل الدخول في تطبيق **زد إكسبريس** يعتمد على **التحقق عبر رقم الهاتف العراقي** باستخدام **رمز OTP** المرسل عبر SMS. النظام متكامل بالكامل مع **Supabase Auth** لتوفير آلية آمنة وموثوقة لتسجيل الدخول.

---

## 🎯 التدفق الكامل للنظام

### 1. **إدخال رقم الهاتف** (`PhoneInputPage`)
```
المستخدم يدخل رقم هاتفه العراقي
    ↓
التحقق من صحة الرقم (يبدأ بـ 7 ويتكون من 10 أرقام)
    ↓
إرسال طلب OTP إلى Supabase
    ↓
الانتقال إلى صفحة إدخال رمز التحقق
```

**الملفات المعنية:**
- [`phone_input_page.dart`](file:///c:/Users/IT/StudioProjects/broker_app/lib/features/authentication/presentation/pages/phone_input_page.dart)
- [`send_otp.dart`](file:///c:/Users/IT/StudioProjects/broker_app/lib/features/authentication/domain/usecases/send_otp.dart)

**المميزات:**
- ✅ التحقق الفوري من صحة الرقم أثناء الكتابة
- ✅ دعم العرض باللغة العربية (RTL)
- ✅ رسائل خطأ واضحة بالعربية
- ✅ واجهة مستخدم بشعار التطبيق

---

### 2. **إدخال رمز التحقق** (`OtpVerificationPage`)
```
المستخدم يدخل رمز OTP المكون من 6 أرقام
    ↓
التحقق من صحة الرمز
    ↓ (في حالة النجاح)
إنشاء/استرجاع جلسة المستخدم
    ↓
التحقق من اكتمال الملف الشخصي
    ↓
- إذا كان الملف مكتمل → الصفحة الرئيسية
- إذا لم يكن مكتمل → صفحة إكمال التسجيل
```

**الملفات المعنية:**
- [`otp_verification_page.dart`](file:///c:/Users/IT/StudioProjects/broker_app/lib/features/authentication/presentation/pages/otp_verification_page.dart)
- [`verify_otp.dart`](file:///c:/Users/IT/StudioProjects/broker_app/lib/features/authentication/domain/usecases/verify_otp.dart)

**المميزات:**
- ✅ 6 حقول منفصلة لإدخال الرمز
- ✅ التحقق التلقائي عند إدخال الرمز كاملاً
- ✅ عداد تنازلي لإعادة إرسال الرمز (120 ثانية)
- ✅ إمكانية إعادة إرسال الرمز
- ✅ رسائل خطأ واضحة للرموز غير الصحيحة
- ✅ واجهة قابلة للتمرير لتجنب Overflow عند فتح لوحة المفاتيح

---

### 3. **إكمال التسجيل** (`RegistrationPage`)
```
المستخدم الجديد يدخل:
    - الاسم الكامل
    - المحافظة
    - القضاء
    ↓
حفظ البيانات في Supabase
    ↓
تسجيل Device Token لإشعارات Firebase
    ↓
الانتقال إلى الصفحة الرئيسية
```

**الملفات المعنية:**
- [`registration_page.dart`](file:///c:/Users/IT/StudioProjects/broker_app/lib/features/authentication/presentation/pages/registration_page.dart)
- [`complete_registration.dart`](file:///c:/Users/IT/StudioProjects/broker_app/lib/features/authentication/domain/usecases/complete_registration.dart)

**المميزات:**
- ✅ قوائم منسدلة ديناميكية للمحافظات والأقضية
- ✅ التحقق من صحة البيانات المدخلة
- ✅ دعم الأسماء العربية والإنجليزية

---

## 🏗️ البنية التقنية (Clean Architecture)

### **طبقة Presentation**
```
Pages/
├── phone_input_page.dart        # صفحة إدخال رقم الهاتف
├── otp_verification_page.dart   # صفحة إدخال رمز التحقق
└── registration_page.dart       # صفحة إكمال التسجيل

Blocs/
├── auth_bloc.dart               # إدارة حالات التوثيق
└── registration_bloc.dart       # إدارة حالات التسجيل

Widgets/
├── auth_header.dart             # شعار وعنوان صفحات التوثيق
├── loading_overlay.dart         # شاشة تحميل
└── otp_input_field.dart         # حقل إدخال OTP
```

### **طبقة Domain**
```
UseCases/
├── send_otp.dart                # إرسال رمز OTP
├── verify_otp.dart              # التحقق من رمز OTP
├── get_current_session.dart     # الحصول على الجلسة الحالية
├── complete_registration.dart   # إكمال تسجيل المستخدم
└── sign_out.dart                # تسجيل الخروج

Entities/
├── user.dart                    # كيان المستخدم
└── auth_session.dart            # كيان الجلسة
```

### **طبقة Data**
```
DataSources/
├── auth_remote_data_source.dart # التواصل مع Supabase
└── auth_local_data_source.dart  # التخزين المحلي

Repositories/
└── auth_repository_impl.dart    # تطبيق Repository Pattern

Models/
├── user_model.dart              # نموذج بيانات المستخدم
└── auth_session_model.dart      # نموذج بيانات الجلسة
```

---

## 🔐 التكامل مع Supabase

### **Phone Authentication Provider**
النظام يستخدم Supabase Phone Auth لإرسال والتحقق من رموز OTP:

```dart
// إرسال OTP
await supabaseClient.auth.signInWithOtp(
  phone: phoneNumber,
  shouldCreateUser: true,
);

// التحقق من OTP
await supabaseClient.auth.verifyOTP(
  phone: phoneNumber,
  token: otp,
  type: OtpType.sms,
);
```

### **تخزين بيانات المستخدم**
البيانات المخزنة في `user_metadata`:
- `name`: الاسم الكامل
- `governorate`: المحافظة
- `district`: القضاء
- `profile_picture`: صورة الملف الشخصي (اختياري)

---

## 🔔 نظام الإشعارات (FCM)

### **تسجيل Device Token**
عند نجاح تسجيل الدخول:
1. يتم الحصول على FCM Token من Firebase
2. يتم تخزينه في جدول `user_fcm_tokens` في Supabase
3. يشمل: `user_id`, `fcm_token`, `platform` (android/ios)

**الملف المعني:**
- [`notifications_service.dart`](file:///c:/Users/IT/StudioProjects/broker_app/lib/core/services/notifications_service.dart)

**الإصلاحات الأخيرة:**
- ✅ إصلاح خطأ Duplicate Key عند تسجيل Token موجود
- ✅ استخدام `onConflict` في عملية `upsert`

---

## 📝 التحسينات المنفذة مؤخراً

### ✅ **الجاهزية للإنتاج**
1. **إزالة وضع التطوير:**
   - حذف كود Bypass OTP من كل الصفحات
   - حذف الأزرار وLogic الخاصة بالتطوير
   - إجبار استخدام Supabase OTP الحقيقي

2. **تحسينات واجهة المستخدم:**
   - إصلاح مشكلة Overflow عند فتح لوحة المفاتيح
   - استبدال الأيقونة العامة بشعار التطبيق
   - إضافة تغذية راجعة واضحة للأخطاء

3. **إصلاح الأخطاء:**
   - إضافة رسائل خطأ عند فشل التحقق من OTP
   - إصلاح خطأ FCM Token Duplicate Key
   - تحسين معالجة الأخطاء عموماً

---

## ⚠️ ما ينقص للإطلاق الفعلي

### 🔴 **متطلبات حرجة (Critical)**

#### 1. **إعداد Supabase Phone Provider**
**الحالة:** ⚠️ **مطلوب**

يجب تفعيل وإعداد Phone Authentication في لوحة تحكم Supabase:

**الخطوات:**
1. الدخول إلى [Supabase Dashboard](https://app.supabase.com)
2. اختيار المشروع → Authentication → Providers
3. تفعيل Phone Provider
4. اختيار مزود SMS (موصى به: Twilio أو MessageBird)
5. إدخال API credentials الخاصة بالمزود
6. تكوين القوالب للرسائل (Templates):
   ```
   Your verification code is: {{ .Token }}
   رمز التحقق الخاص بك: {{ .Token }}
   ```

**التكلفة المتوقعة:**
- Twilio: ~$0.05 لكل رسالة SMS للعراق
- MessageBird: ~$0.04 لكل رسالة

**بدون هذا الإعداد:** النظام لن يرسل أي رموز OTP فعلية!

---

#### 2. **تحديث AppConfig للإنتاج**
**الملف:** [`app_config.dart`](file:///c:/Users/IT/StudioProjects/broker_app/lib/core/config/app_config.dart)

**الإعدادات الواجب تغييرها:**
```dart
class AppConfig {
  static const bool isDevelopment = false; // ⚠️ تغيير من true إلى false
  static const bool bypassOtpInDevelopment = false; // تأكيد false
  static const bool showDebugInfo = false;
  static const bool enableVerboseLogging = false;
}
```

---

#### 3. **إزالة Print Statements**
**الحالة:** ⚠️ **مطلوب للأمان والأداء**

حالياً الكود يحتوي على العديد من `print()` statements لأغراض التطوير:
- معلومات حساسة مثل أرقام الهواتف
- Tokens
- User IDs

**الحل:**
- استبدال `print()` بنظام Logging محترف (مثل `logger` package)
- أو حذفها نهائياً في Production build

---

### 🟡 **متطلبات مهمة (Important)**

#### 4. **Rate Limiting & Security**
**موصى به:**
1. **حد أقصى لمحاولات OTP:**
   - 3 محاولات خاطئة → حظر مؤقت (5 دقائق)
   - 5 محاولات → حظر لمدة ساعة

2. **حد أقصى لطلبات OTP:**
   - رقم واحد: max 5 طلبات في الساعة
   - IP واحد: max 20 طلب في الساعة

**التنفيذ:** يمكن عمله عبر Supabase Edge Functions أو في Backend

---

#### 5. **معالجة حالات الخطأ النادرة**
**السيناريوهات:**
- فقدان الاتصال بالإنترنت أثناء التحقق
- انتهاء صلاحية Session
- مشاكل في تسجيل FCM Token

**التحسينات المطلوبة:**
- Retry logic للعمليات الفاشلة
- رسائل خطأ أكثر تحديداً
- Offline mode handling

---

#### 6. **الاختبارات (Testing)**
**الحالة:** ❌ **غير موجودة**

**مطلوب:**
1. **Unit Tests** لـ:
   - Validators (phone, OTP)
   - UseCases
   - Repositories

2. **Integration Tests** لـ:
   - التدفق الكامل للتوثيق
   - التعامل مع Supabase

3. **Widget Tests** لـ:
   - الصفحات الثلاث الرئيسية
   - حالات الخطأ

---

### 🟢 **تحسينات اختيارية (Nice to Have)**

#### 7. **Analytics & Monitoring**
- تتبع معدل نجاح/فشل OTP
- قياس وقت التحقق
- مراقبة الأخطاء في Production (مثل Sentry)

#### 8. **استعادة الحساب**
- آلية لاستعادة الحساب في حال تغيير الرقم
- دعم فني للمشاكل

#### 9. **تحسين UX**
- Auto-paste OTP من الرسائل (Android/iOS)
- Biometric login بعد أول تسجيل دخول
- Remember device

---

## 📋 Checklist النشر للإنتاج

### **قبل النشر مباشرة:**
- [ ] تفعيل Phone Provider في Supabase
- [ ] إعداد مزود SMS (Twilio/MessageBird)
- [ ] تحديث `AppConfig.isDevelopment = false`
- [ ] إزالة/تعطيل Debug prints
- [ ] اختبار التدفق الكامل على أجهزة حقيقية
- [ ] التحقق من عمل FCM notifications
- [ ] مراجعة Rate limits في Supabase
- [ ] تفعيل RLS policies في جداول Supabase
- [ ] Backup لقاعدة البيانات

### **بعد النشر:**
- [ ] مراقبة معدل نجاح OTP
- [ ] متابعة تكاليف SMS
- [ ] مراقبة الأخطاء والتقارير
- [ ] جمع تعليقات المستخدمين

---

## 🔍 الملفات الرئيسية للمراجعة

| الملف | المسار | الوصف |
|-------|--------|--------|
| **AppConfig** | `lib/core/config/app_config.dart` | إعدادات البيئة |
| **PhoneInputPage** | `lib/features/authentication/presentation/pages/phone_input_page.dart` | صفحة إدخال الهاتف |
| **OtpVerificationPage** | `lib/features/authentication/presentation/pages/otp_verification_page.dart` | صفحة التحقق |
| **AuthRemoteDataSource** | `lib/features/authentication/data/datasources/auth_remote_data_source.dart` | Supabase integration |
| **NotificationsService** | `lib/core/services/notifications_service.dart` | FCM handling |

---

## 📞 معلومات الدعم

للأسئلة أو المساعدة في الإعداد:
- مراجعة [Supabase Phone Auth Docs](https://supabase.com/docs/guides/auth/phone-login)
- مراجعة [Twilio Pricing for Iraq](https://www.twilio.com/sms/pricing/iq)

---

**آخر تحديث:** 23 يناير 2026  
**الحالة:** ✅ جاهز للإطلاق بعد إعداد Phone Provider
