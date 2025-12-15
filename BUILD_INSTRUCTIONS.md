# تعليمات البناء - Voice Notes App

## ⚠️ مشكلة البناء الحالية وحلها

### المشكلة:
```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

---

## ✅ الحل (خطوات مفصلة):

### **الخطوة 1: تفعيل Developer Mode في Windows**

#### الطريقة الأولى (الأسرع):
1. اضغط `Win + R`
2. اكتب: `ms-settings:developers`
3. اضغط Enter
4. **فعّل "Developer Mode"**

#### الطريقة الثانية (يدوي):
1. افتح **Settings** (الإعدادات)
2. اذهب إلى **Privacy & Security**
3. اختر **For Developers**
4. **فعّل "Developer Mode"**
5. انتظر التثبيت (قد يستغرق دقيقة)

#### الطريقة الثالثة (PowerShell كـ Admin):
```powershell
# Run as Administrator
Start-Process ms-settings:developers
```

---

### **الخطوة 2: أعد تشغيل Terminal/CMD**

بعد تفعيل Developer Mode:
```bash
# أغلق Terminal/CMD الحالي وافتح واحد جديد
```

---

### **الخطوة 3: Build التطبيق**

#### لـ Debug APK (للاختبار):
```bash
cd D:\speechtotext
flutter clean
flutter pub get
flutter build apk --debug
```

**الملف سيكون في:**
```
D:\speechtotext\build\app\outputs\flutter-apk\app-debug.apk
```

#### لـ Release APK:
```bash
flutter build apk --release
```

**الملف سيكون في:**
```
D:\speechtotext\build\app\outputs\flutter-apk\app-release.apk
```

#### لـ App Bundle (للنشر على Google Play):
```bash
flutter build appbundle --release
```

**الملف سيكون في:**
```
D:\speechtotext\build\app\outputs\bundle\release\app-release.aab
```

---

## 🔧 حل مشاكل إضافية:

### مشكلة: Kotlin Compilation Error
```
Execution failed for task ':speech_to_text:compileReleaseKotlin'
```

**الحل:**
```bash
# تحديث Gradle cache
cd D:\speechtotext\android
gradlew clean

# أو من المجلد الرئيسي
cd D:\speechtotext
flutter clean
flutter pub get
flutter build apk --debug
```

---

### مشكلة: Out of Memory
```
Java heap space error
```

**الحل:**
أضف في `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m
```

---

### مشكلة: SDK License
```
Android SDK licenses not accepted
```

**الحل:**
```bash
flutter doctor --android-licenses
# اضغط 'y' على كل السؤالات
```

---

## 📱 تثبيت APK على الجهاز:

### عبر USB:
```bash
# تأكد من تفعيل USB Debugging على الجهاز
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### عبر نقل الملف:
1. انسخ `app-debug.apk`
2. انقله للجهاز
3. افتحه وثبّت

---

## ✅ Checklist قبل البناء:

- [ ] Developer Mode مفعّل
- [ ] Flutter SDK محدّث (`flutter --version`)
- [ ] Android SDK مثبت
- [ ] Java 11 مثبت
- [ ] Keystore موجود (للـ release)
- [ ] `key.properties` موجود (للـ release)

---

## 🎯 Build للنشر على Google Play:

### 1. تأكد من الـ Keystore:
```bash
# تحقق من وجود الملف
ls D:\speechtotext\android\app\voice-keystore.jks
```

### 2. تحقق من key.properties:
```bash
# يجب أن يحتوي على:
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=voice-key
storeFile=voice-keystore.jks
```

### 3. Build App Bundle:
```bash
cd D:\speechtotext
flutter clean
flutter pub get
flutter build appbundle --release
```

### 4. الملف النهائي:
```
D:\speechtotext\build\app\outputs\bundle\release\app-release.aab
```

---

## 🐛 Troubleshooting:

### المشكلة: "Command not found: flutter"
**الحل:** أضف Flutter للـ PATH

### المشكلة: "No connected devices"
**الحل:**
- وصّل الجهاز عبر USB
- فعّل USB Debugging
- أو استخدم Emulator

### المشكلة: "Gradle daemon disappeared"
**الحل:**
```bash
cd android
./gradlew --stop
cd ..
flutter clean
flutter build apk
```

---

## 📊 معلومات البناء:

- **Min SDK:** 21 (Android 5.0)
- **Target SDK:** Latest
- **Compile SDK:** Latest
- **Java Version:** 11
- **Kotlin Version:** Latest

---

## 🚀 أوامر سريعة:

### تنظيف كامل:
```bash
flutter clean
cd android
./gradlew clean
cd ..
```

### بناء سريع (debug):
```bash
flutter build apk --debug
```

### بناء نهائي (release):
```bash
flutter build appbundle --release
```

### فحص المشاكل:
```bash
flutter doctor -v
flutter analyze
```

---

## 📝 ملاحظات:

1. **Debug APK** أكبر حجماً من Release
2. **App Bundle** هو المفضل لـ Google Play (أصغر حجماً)
3. **Release Build** يحتاج Keystore
4. **Developer Mode** ضروري للبناء على Windows

---

## 🎉 بعد البناء الناجح:

1. ✅ اختبر APK على جهاز حقيقي
2. ✅ جرّب جميع الميزات:
   - Dark Mode
   - Speech-to-Text
   - Undo Delete
   - Charts
3. ✅ خذ Screenshots
4. ✅ ارفع على Google Play Console

---

**آخر تحديث:** 12 ديسمبر 2024
**الإصدار:** 2.0.0+4
**الحالة:** ✅ تم البناء بنجاح - APKs جاهزة للاختبار

---

## 💡 نصيحة نهائية:

**إذا واجهت أي مشكلة:**
1. تأكد من Developer Mode مفعّل
2. أعد تشغيل Terminal
3. نفذ `flutter clean`
4. حاول مرة أخرى

**حظاً موفقاً!** 🚀
