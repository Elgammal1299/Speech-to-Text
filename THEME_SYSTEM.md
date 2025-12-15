# نظام الثيم (Theme System)

تم تطبيق نظام ثيم متكامل على التطبيق يدعم الوضع الفاتح والداكن بشكل كامل.

## 📁 البنية

```
lib/
  └── theme/
      ├── app_colors.dart    # تعريف جميع الألوان المستخدمة في التطبيق
      └── app_theme.dart     # تعريف الثيمات الكاملة (فاتح وداكن)
```

## 🎨 الألوان (AppColors)

### الألوان الأساسية
- `primary` - اللون الأساسي للتطبيق (#2196F3)
- `primaryDark` - نسخة أغمق من اللون الأساسي (#1976D2)
- `primaryLight` - نسخة أفتح من اللون الأساسي (#64B5F6)
- `secondary` - اللون الثانوي (#03A9F4)
- `accent` - اللون المميز (#00BCD4)

### ألوان النظام
- `success` - لون النجاح (#4CAF50)
- `error` - لون الخطأ (#F44336)
- `warning` - لون التحذير (#FF9800)
- `info` - لون المعلومات (#2196F3)

### ألوان التسجيل
- `recording` - لون التسجيل الصوتي (#E53935)
- `recordingLight` - نسخة فاتحة (#EF5350)

### ألوان الوضع الفاتح (Light Mode)
- `lightBackground` - خلفية الشاشة (#FAFAFA)
- `lightSurface` - خلفية العناصر (#FFFFFF)
- `lightSurfaceVariant` - خلفية العناصر البديلة (#F5F5F5)
- `lightTextPrimary` - النص الأساسي (#212121)
- `lightTextSecondary` - النص الثانوي (#757575)
- `lightTextTertiary` - النص الثالث (#9E9E9E)

### ألوان الوضع الداكن (Dark Mode)
- `darkBackground` - خلفية الشاشة (#121212)
- `darkSurface` - خلفية العناصر (#1E1E1E)
- `darkSurfaceVariant` - خلفية العناصر البديلة (#2C2C2C)
- `darkTextPrimary` - النص الأساسي (#E0E0E0)
- `darkTextSecondary` - النص الثانوي (#B0B0B0)
- `darkTextTertiary` - النص الثالث (#808080)

### Gradients
- `primaryGradient` - تدرج اللون الأساسي
- `recordingGradient` - تدرج التسجيل
- `accentGradient` - تدرج اللون المميز

### Helper Methods
```dart
AppColors.primaryWithOpacity(0.5)    // لون أساسي بشفافية
AppColors.errorWithOpacity(0.3)      // لون خطأ بشفافية
AppColors.successWithOpacity(0.2)    // لون نجاح بشفافية
```

## 🌓 الثيمات (AppTheme)

### استخدام الثيمات

```dart
// في main.dart
MaterialApp(
  theme: AppTheme.lightTheme,      // الثيم الفاتح
  darkTheme: AppTheme.darkTheme,   // الثيم الداكن
  themeMode: ThemeMode.system,     // تلقائي حسب نظام التشغيل
)
```

### الوصول للثيم الحالي

```dart
// في أي Widget
final theme = Theme.of(context);
final isDark = theme.brightness == Brightness.dark;

// استخدام الألوان
Container(
  color: theme.colorScheme.surface,
  child: Text(
    'مرحباً',
    style: theme.textTheme.titleLarge,
  ),
)
```

### Helper Methods للألوان

```dart
// الحصول على لون النص حسب الثيم الحالي
Color textColor = AppTheme.getTextColor(context, isPrimary: true);

// الحصول على لون السطح
Color surfaceColor = AppTheme.getSurfaceColor(context);

// الحصول على لون الخلفية
Color bgColor = AppTheme.getBackgroundColor(context);
```

## 📝 أمثلة الاستخدام

### مثال 1: Container بألوان الثيم

```dart
Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: isDark ? AppColors.darkCardShadow : AppColors.lightCardShadow,
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Text(
    'محتوى',
    style: theme.textTheme.bodyMedium,
  ),
)
```

### مثال 2: Button بألوان مخصصة

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  ),
  child: Text('حفظ'),
)
```

### مثال 3: نص بألوان متعددة

```dart
Column(
  children: [
    Text('عنوان', style: theme.textTheme.titleLarge),
    Text('عنوان فرعي', style: theme.textTheme.bodyMedium),
    Text('تفاصيل', style: theme.textTheme.bodySmall),
  ],
)
```

## ✅ أفضل الممارسات

### ✓ استخدم
```dart
// استخدام الثيم
color: theme.colorScheme.primary
style: theme.textTheme.titleMedium

// استخدام AppColors للألوان المحددة
color: AppColors.recording
gradient: AppColors.primaryGradient
```

### ✗ تجنب
```dart
// تجنب الألوان الثابتة
color: Colors.blue
color: Color(0xFF2196F3)

// تجنب الأنماط الثابتة
style: TextStyle(fontSize: 16, color: Colors.black)
```

## 🔄 تبديل الثيم

يتم التحكم في الثيم من خلال `ThemeProvider`:

```dart
// في settings_screen.dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return Switch(
      value: themeProvider.isDarkMode,
      onChanged: (value) => themeProvider.toggleTheme(),
    );
  },
)
```

## 📋 التعديلات على الشاشات

تم تحديث جميع الشاشات التالية لاستخدام نظام الثيم:

- ✅ `main.dart` - الثيم الرئيسي
- ✅ `main_screen.dart` - الشاشة الرئيسية وشريط التنقل
- ✅ `voice_recording_screen.dart` - شاشة التسجيل
- ✅ `settings_screen.dart` - شاشة الإعدادات
- ✅ `history_screen.dart` - شاشة السجل
- ✅ `statistics_screen.dart` - شاشة الإحصائيات
- ✅ `note_detail_screen.dart` - شاشة تفاصيل الملاحظة

## 🎯 مزايا النظام الجديد

1. **دعم كامل للوضع الداكن** - جميع الشاشات تدعم الثيم الداكن
2. **ثبات الألوان** - جميع الألوان معرفة في مكان واحد
3. **سهولة الصيانة** - تغيير الألوان في مكان واحد يؤثر على كل التطبيق
4. **Material Design 3** - يستخدم أحدث معايير التصميم
5. **Google Fonts** - يستخدم خط Inter في جميع النصوص
6. **Responsive** - يستجيب تلقائياً لتغييرات نظام التشغيل

## 🚀 التطوير المستقبلي

لإضافة لون جديد:
1. أضف اللون في `app_colors.dart`
2. استخدمه في الشاشات عبر `AppColors.yourColor`

لتعديل الثيم:
1. عدّل في `app_theme.dart` في `lightTheme` أو `darkTheme`
2. التغييرات ستظهر تلقائياً في كل التطبيق

---

**تم التطوير بواسطة:** Claude Code
**التاريخ:** 2025-12-15
