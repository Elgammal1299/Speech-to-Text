# دليل رفع التطبيق على Google Play Store

**App Bundle Ready:** ✅ `app-release.aab` (43 MB)

---

## الخطوات الكاملة للنشر على Google Play

### المرحلة 1: إعداد Google Play Console

#### 1. إنشاء حساب مطور (إذا لم يكن موجوداً)
- الذهاب إلى: https://play.google.com/console
- تسجيل الدخول بحساب Google
- دفع رسوم التسجيل لمرة واحدة: **$25**
- ملء معلومات المطور

#### 2. إنشاء تطبيق جديد
1. اضغط **"Create app"**
2. املأ المعلومات:
   - **App name:** Voice Notes
   - **Default language:** English (United States)
   - **App or game:** App
   - **Free or paid:** Free
3. وافق على السياسات والإرشادات

---

### المرحلة 2: رفع App Bundle

#### 1. الذهاب إلى قسم Production
```
Dashboard → Production → Create new release
```

#### 2. رفع ملف AAB
```
Path: D:\speechtotext\build\app\outputs\bundle\release\app-release.aab
Size: 43 MB
```

**الخطوات:**
1. اضغط **"Upload"**
2. اختر الملف: `app-release.aab`
3. انتظر حتى يكتمل الرفع والتحقق
4. ✅ سيظهر: **Version 2.0.0 (4)** بعد الرفع الناجح

---

### المرحلة 3: إكمال Store Listing

#### 1. App Details
```
Dashboard → Store presence → Main store listing
```

**المعلومات المطلوبة:**

**App name:** Voice Notes

**Short description (80 characters max):**
```
Record voice notes, transcribe speech to text, organize with categories
```

**Full description (4000 characters max):**
استخدم المحتوى من: [store_listing/app_description.md](d:/speechtotext/store_listing/app_description.md)

**App category:**
- Primary: **Productivity**
- Tags: voice recorder, speech to text, notes, transcription

**Contact details:**
- Email: [your-email@example.com]
- Phone: (optional)
- Website: (optional)

---

#### 2. Graphics (الصور المطلوبة)

##### App Icon
- **الحجم:** 512 x 512 px
- **الصيغة:** PNG (32-bit)
- **ملاحظة:** استخدم نفس الأيقونة من `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` لكن بحجم 512x512

##### Feature Graphic (صورة بارزة)
- **الحجم:** 1024 x 500 px
- **الصيغة:** PNG or JPEG
- **المحتوى المقترح:**
  - اسم التطبيق بخط كبير
  - أيقونة التطبيق
  - شعار: "Record • Transcribe • Organize"
  - خلفية متدرجة بلون أزرق (لون التطبيق)

##### Screenshots (8 صور على الأقل)
- **الحجم:** 16:9 aspect ratio (مثال: 1920 x 1080 px)
- **الصيغة:** PNG or JPEG
- **العدد:** من 2 إلى 8 صور

**Screenshots المطلوبة:**
1. **Recording Screen** - شاشة التسجيل مع العداد
2. **Live Transcription** - التحويل النصي أثناء التسجيل
3. **History Screen** - قائمة الملاحظات مع البحث
4. **Note Details** - تفاصيل الملاحظة مع المشغل
5. **Statistics Charts** - الإحصائيات مع الـ Pie Chart
6. **Settings Light Mode** - الإعدادات في الوضع الفاتح
7. **Settings Dark Mode** - الإعدادات في الوضع الداكن
8. **Categories** - عرض الفئات المختلفة

**كيفية أخذ Screenshots:**
1. قم بتشغيل التطبيق على emulator أو جهاز حقيقي
2. استخدم أداة Screenshot في Android Studio
3. أو استخدم أداة على الجهاز نفسه
4. تأكد من الدقة العالية والوضوح

---

#### 3. Categorization

```
Dashboard → Store presence → Store settings
```

**App category:** Productivity
**Tags:** (اختر 5 من القائمة)
- Voice recorder
- Productivity
- Note-taking
- Speech recognition
- Audio

---

### المرحلة 4: Privacy Policy

#### 1. رفع Privacy Policy
**الخيارات:**
- رفع ملف `privacy_policy.md` على موقع GitHub أو Google Sites
- أو استخدام خدمة مثل app-privacy-policy-generator.com

**الرابط المطلوب:**
```
https://your-domain.com/privacy-policy.html
```

#### 2. Data Safety Section
```
Dashboard → App content → Data safety
```

**Data collected:** None (لا يتم جمع بيانات)

**Data shared:** None (لا يتم مشاركة بيانات)

**Security practices:**
- ✅ Data is encrypted in transit (HTTPS)
- ✅ Data is stored locally on device only
- ✅ You can request data deletion (user can delete notes)

**Permissions used:**
- **RECORD_AUDIO:**
  - Purpose: To record voice notes
  - Required: Yes
- **READ/WRITE_EXTERNAL_STORAGE:**
  - Purpose: To save audio files locally
  - Required: Yes

---

### المرحلة 5: Content Rating

```
Dashboard → App content → Content rating
```

**Start questionnaire:**
1. اختر **Utility, Productivity, Communication, or Other**
2. أجب على الأسئلة (كلها "No" للتطبيق البسيط)
3. **التقييم المتوقع:** Everyone

---

### المرحلة 6: App Access

```
Dashboard → App content → App access
```

**All functionality is available without special access:** Yes

---

### المرحلة 7: Ads Declaration

```
Dashboard → App content → Ads
```

**Does your app contain ads?** No ✅

---

### المرحلة 8: Target Audience

```
Dashboard → App content → Target audience
```

**Target age group:** 18 and over (or 13 and over)

---

### المرحلة 9: News Apps Declaration

```
Dashboard → App content → News
```

**Is your app a news app?** No

---

### المرحلة 10: COVID-19 Contact Tracing

```
Dashboard → App content → COVID-19 apps
```

**Is your app a COVID-19 contact tracing or status app?** No

---

### المرحلة 11: Data Deletion

```
Dashboard → App content → Data deletion
```

**Can users request deletion of their data?**
- Yes (users can delete their notes manually in the app)
- No need for external URL (in-app deletion)

---

### المرحلة 12: Release Notes

عند رفع الـ AAB، أضف release notes:

**English:**
```
Version 2.0.0 - Major Update

New Features:
• Dark Mode - Instant theme switching
• Speech-to-Text - Real-time voice transcription
• Undo Delete - Restore deleted notes
• Interactive Charts - Beautiful category statistics
• Professional Typography - Enhanced readability

Improvements:
• Optimized app size
• Better performance
• Modern Material Design 3 UI
```

**Arabic (if supporting):**
```
الإصدار 2.0.0 - تحديث كبير

ميزات جديدة:
• الوضع الداكن - تبديل فوري للثيم
• تحويل الصوت لنص - نسخ مباشر أثناء التسجيل
• التراجع عن الحذف - استعادة الملاحظات المحذوفة
• رسوم بيانية تفاعلية - إحصائيات جميلة للفئات
• خطوط احترافية - قابلية قراءة محسّنة

تحسينات:
• تحسين حجم التطبيق
• أداء أفضل
• واجهة عصرية Material Design 3
```

---

### المرحلة 13: Countries/Regions

```
Dashboard → Production → Countries/regions
```

**Available in:** All countries (أو اختر دول محددة)

**Price:** Free

---

### المرحلة 14: Review and Publish

#### 1. التحقق من جميع الأقسام
تأكد أن جميع الأقسام بها علامة ✅:
- [ ] Store listing completed
- [ ] Privacy policy added
- [ ] Content rating received
- [ ] App content declarations completed
- [ ] Screenshots uploaded (8+)
- [ ] Feature graphic uploaded
- [ ] App icon uploaded
- [ ] App Bundle uploaded

#### 2. إرسال للمراجعة
```
Dashboard → Production → Review release
```

**Review time:** عادة من 1-7 أيام

---

## ملاحظات مهمة

### ✅ Do's:
- تأكد من اختبار التطبيق جيداً قبل الرفع
- استخدم screenshots واضحة وذات جودة عالية
- اكتب وصف دقيق وجذاب
- أضف privacy policy واضحة
- حدّث release notes مع كل نسخة جديدة

### ❌ Don'ts:
- لا تستخدم keywords مكررة في الوصف
- لا تستخدم صور مضللة
- لا تدّعي features غير موجودة
- لا تنسخ وصف من تطبيقات أخرى
- لا تطلب تقييمات بطرق ملحّة

---

## بعد النشر

### 1. مراقبة الأداء
- **Crashes:** تحقق من قسم Vitals
- **Reviews:** رد على تقييمات المستخدمين
- **Statistics:** راقب التحميلات والاستخدام

### 2. التحديثات المستقبلية
عند إصدار تحديث:
1. قم ببناء AAB جديد
2. زود versionCode في `build.gradle.kts`
3. ارفع على Production → Create new release
4. أضف release notes
5. انشر التحديث

---

## معلومات التطبيق الحالي

```
Application ID: com.voicespeech.app
Version Name: 2.0.0
Version Code: 4
Min SDK: 21 (Android 5.0)
Target SDK: Latest (Android 14)

File: app-release.aab
Size: 43 MB
Status: ✅ Ready for upload
```

---

## روابط مفيدة

- **Google Play Console:** https://play.google.com/console
- **Developer Policy:** https://play.google.com/about/developer-content-policy/
- **App Quality Guidelines:** https://developer.android.com/quality
- **Asset Requirements:** https://support.google.com/googleplay/android-developer/answer/9866151

---

## دعم

إذا واجهت مشاكل:
1. راجع [Google Play Console Help](https://support.google.com/googleplay/android-developer)
2. تحقق من [store_listing/google_play_checklist.md](d:/speechtotext/store_listing/google_play_checklist.md)
3. راجع رسائل الخطأ في Console

---

**Good luck with your app launch! 🚀**

**آخر تحديث:** 12 ديسمبر 2024
**الحالة:** ✅ AAB جاهز للرفع
