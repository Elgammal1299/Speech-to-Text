# Google Play Store Publishing Checklist

## Pre-Publishing Requirements

### 1. App Assets (REQUIRED)

#### App Icon
- [ ] **512x512 PNG** - High-res icon (32-bit PNG with alpha)
- [ ] **Adaptive Icon** - Foreground and background layers
- [ ] Icon follows Material Design guidelines
- [ ] No transparency in outer 33% of icon (for adaptive)

#### Feature Graphic
- [ ] **1024 x 500 pixels** PNG or JPEG
- [ ] Showcases app name and main feature
- [ ] No transparency
- [ ] High quality, professional design

#### Screenshots (REQUIRED - Minimum 2, Maximum 8)
Required screenshots:
- [ ] **Phone Screenshot 1:** Voice recording screen (showing timer and recording UI)
- [ ] **Phone Screenshot 2:** History screen with search and categories
- [ ] **Phone Screenshot 3:** Note detail screen with audio player and waveform
- [ ] **Phone Screenshot 4:** Statistics screen with charts
- [ ] **Phone Screenshot 5:** Settings screen (English UI)
- [ ] **Phone Screenshot 6:** Settings screen (Arabic UI - RTL)
- [ ] **Phone Screenshot 7:** Dark mode example
- [ ] **Phone Screenshot 8:** Export/Share feature demonstration

**Screenshot Requirements:**
- Format: PNG or JPEG (no alpha)
- Min dimension: 320px
- Max dimension: 3840px
- Aspect ratio: Between 16:9 and 9:16

#### Tablet Screenshots (OPTIONAL but recommended)
- [ ] 7-inch tablet screenshots (1-8 images)
- [ ] 10-inch tablet screenshots (1-8 images)

#### Promotional Video (OPTIONAL but recommended)
- [ ] YouTube video URL (30-120 seconds)
- [ ] Demonstrates key features
- [ ] Professional quality

---

### 2. Store Listing Content

#### App Title
- [ ] **Max 50 characters**
- Current: "Voice Notes - Speech to Text" (29 characters) ✓

#### Short Description
- [ ] **Max 80 characters**
- English: "Record, transcribe, and organize your voice notes with ease and privacy." (71 chars) ✓
- Arabic: "سجّل، حوّل لنص، ونظّم ملاحظاتك الصوتية بسهولة وخصوصية." ✓

#### Full Description
- [ ] **Max 4000 characters**
- English version complete ✓
- Arabic version complete ✓
- Includes key features, benefits, and use cases ✓

#### App Category
- [ ] Primary: **Productivity**
- [ ] Secondary: **Tools**

#### Tags/Keywords
- [ ] Relevant keywords added for discovery
- [ ] Both English and Arabic keywords ✓

---

### 3. Privacy & Data Safety

#### Privacy Policy
- [ ] Privacy policy created ✓ (`privacy_policy.md`)
- [ ] **Privacy Policy URL** - Must be hosted publicly
  - Options: GitHub Pages, Google Sites, or your website
  - [ ] Host privacy_policy.md and get URL
  - [ ] Add URL to Google Play Console
  - [ ] Add clickable link in app Settings ✓ (placeholder added)

#### Data Safety Section (Google Play Console)
**Data Collection Declaration:**

**Data Collected: NONE** (select "No" for all)
- [ ] Location: No
- [ ] Personal info: No
- [ ] Financial info: No
- [ ] Photos and videos: No
- [ ] Audio files: No (stored locally only, not collected)
- [ ] Files and docs: No
- [ ] Calendar: No
- [ ] Contacts: No
- [ ] App activity: No
- [ ] App info and performance: No
- [ ] Device or other IDs: No

**Data Sharing: NONE**
- [ ] No data is shared with third parties

**Security Practices:**
- [ ] Data is encrypted in transit: N/A (no network transmission)
- [ ] Data is encrypted at rest: Partial (Android system encryption)
- [ ] Users can request data deletion: Yes (via app settings)

---

### 4. Permissions Justification

Declare and justify each permission:

#### RECORD_AUDIO (DANGEROUS - Runtime)
- **Purpose:** Recording voice notes
- **Justification:** "Required to capture audio when user presses the record button. Audio is stored locally on device."
- [ ] Permission declared in manifest ✓
- [ ] Runtime permission requested in code ✓

#### INTERNET (NORMAL)
- **Purpose:** Speech-to-text functionality (optional)
- **Justification:** "Used only for optional speech-to-text feature via Android Speech Recognition API. Not required for basic recording."
- [ ] Permission declared in manifest ✓
- [ ] Actually needed? Review after STT implementation

#### BLUETOOTH, BLUETOOTH_ADMIN, BLUETOOTH_CONNECT
- **Purpose:** Audio routing to Bluetooth devices
- **Justification:** "Allows recording and playback through Bluetooth headsets/speakers"
- [ ] Permission declared in manifest ✓
- [ ] Actually needed? Review if used ⚠️

**Action Items:**
- [ ] Test app without INTERNET permission
- [ ] Test app without BLUETOOTH permissions
- [ ] Remove unnecessary permissions before release

---

### 5. App Content & Rating

#### Content Rating Questionnaire
Answer the IARC questionnaire in Play Console:

**Expected Rating: Everyone (PEGI 3, ESRB E)**

Key Questions:
- [ ] Violence: None
- [ ] Sexual content: None
- [ ] Language: None
- [ ] Controlled substances: None
- [ ] Gambling: None
- [ ] User interaction: None (no social features)
- [ ] Shares user location: No
- [ ] Unrestricted internet access: No (optional for STT only)

#### Target Audience
- [ ] Age group: All ages (Everyone)
- [ ] Appeal to children: No special appeal

---

### 6. Technical Requirements

#### App Bundle
- [ ] Generate signed App Bundle (.aab) instead of APK
- [ ] Enable R8/ProGuard obfuscation
- [ ] Test in Release mode, not Debug

**Build Command:**
```bash
flutter build appbundle --release
```

**Signing:**
- [ ] Keystore exists ✓ (voice-keystore.jks)
- [ ] Keystore password secured
- [ ] Upload key to Google Play Console (first time only)
- [ ] Enable Google Play App Signing (recommended)

#### Android Version Support
Current configuration:
- [ ] Check minimum SDK version (should be API 21+)
- [ ] Target SDK: API 34 (Android 14) or latest
- [ ] Compile SDK: Latest

**Update android/app/build.gradle:**
```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 4
        versionName "2.0.0"
    }
}
```

---

### 7. Testing Requirements

#### Internal Testing Track
- [ ] Upload first version to Internal Testing
- [ ] Add internal testers (your email)
- [ ] Test on at least 2-3 different devices
- [ ] Test on different Android versions (API 21, 28, 33+)

#### Pre-Launch Report (Automatic)
- [ ] Review Firebase Test Lab results
- [ ] Fix any crashes detected
- [ ] Address any warnings

#### Manual Testing Checklist
- [ ] Install fresh on clean device
- [ ] Test all permissions (grant/deny)
- [ ] Test recording functionality
- [ ] Test playback
- [ ] Test dark mode toggle
- [ ] Test undo delete
- [ ] Test app lifecycle (minimize, restore, kill)
- [ ] Test with low storage
- [ ] Test offline (airplane mode)
- [ ] Test Arabic interface (RTL)
- [ ] No crashes or ANRs (App Not Responding)

---

### 8. Release Configuration

#### Build Type
- [ ] Release build (not debug)
- [ ] ProGuard/R8 rules configured
- [ ] No debug logs in production

#### Version Management
- [ ] versionCode: 4 ✓
- [ ] versionName: "2.0.0" ✓
- [ ] Increment for each release

---

### 9. Store Listing Translations

#### Supported Languages
- [ ] English (en-US) - Default ✓
- [ ] Arabic (ar) ✓

For each language:
- [ ] App title
- [ ] Short description
- [ ] Full description
- [ ] Screenshots with localized UI

---

### 10. Additional Compliance

#### Google Play Policies
- [ ] App complies with [Google Play Developer Program Policies](https://play.google.com/about/developer-content-policy/)
- [ ] App complies with [Developer Distribution Agreement](https://play.google.com/about/developer-distribution-agreement.html)
- [ ] No misleading claims
- [ ] No copyrighted content without permission
- [ ] No spam or deceptive behavior

#### Accessibility (Recommended)
- [ ] Content descriptions for images/icons
- [ ] TalkBack support tested
- [ ] Color contrast meets WCAG guidelines

#### Android App Quality Guidelines
- [ ] Follows Material Design principles ✓
- [ ] Handles screen rotations
- [ ] Back button works correctly
- [ ] No hardcoded text (uses localization) ⚠️ (pending)

---

### 11. Post-Publish Monitoring

#### After First Release
- [ ] Monitor crash reports in Play Console
- [ ] Respond to user reviews (within 24-48 hours)
- [ ] Track installations and uninstalls
- [ ] Monitor ANR (App Not Responding) rate
- [ ] Keep ANR rate < 0.47%
- [ ] Keep crash rate < 1.09%

#### Release Strategy
- [ ] Start with Internal Testing (0-100 users)
- [ ] Progress to Closed Testing (optional, 100+ users)
- [ ] Open Testing (optional, public beta)
- [ ] Production with Staged Rollout:
  - Day 1: 10% of users
  - Day 2-3: 25% of users
  - Day 4-5: 50% of users
  - Day 6-7: 100% of users

---

## Files to Prepare

### Required Files Checklist
- [x] `privacy_policy.md` - Created ✓
- [x] `store_listing/app_description.md` - Created ✓
- [ ] `store_listing/screenshots/` - Need to capture
- [ ] `store_listing/feature_graphic.png` - Need to create
- [ ] `store_listing/app_icon_512.png` - Need to create
- [ ] Signed App Bundle (.aab)

### Screenshot Naming Convention
```
phone_en_01_recording.png
phone_en_02_history.png
phone_en_03_detail.png
phone_en_04_statistics.png
phone_en_05_settings.png
phone_ar_06_settings_rtl.png
phone_07_dark_mode.png
phone_08_export.png
```

---

## Timeline

### Before Phase 1 Complete
- [x] Dark Mode ✓
- [x] Undo Delete ✓
- [x] Privacy Policy ✓
- [x] App Descriptions ✓
- [x] Version bump to 2.0.0 ✓

### Before Phase 2 Complete (Localization)
- [ ] Full Arabic translation
- [ ] Arabic screenshots
- [ ] RTL layout testing

### Before Phase 3 Complete (Speech-to-Text)
- [ ] Update privacy policy with STT details
- [ ] Update app description with STT features
- [ ] New screenshots showing STT

### Before Production Release
- [ ] All features complete
- [ ] All tests passed
- [ ] All assets created
- [ ] Internal testing completed
- [ ] Pre-launch report reviewed
- [ ] All compliance checks done

---

## Quick Reference URLs

- **Google Play Console:** https://play.google.com/console
- **Developer Policies:** https://play.google.com/about/developer-content-policy/
- **App Quality Guidelines:** https://developer.android.com/quality
- **Material Design:** https://material.io/design
- **Android App Bundle:** https://developer.android.com/guide/app-bundle

---

## Notes

⚠️ **IMPORTANT BEFORE FIRST PUBLISH:**
1. Host the privacy policy and get a public URL
2. Create all required graphics (icon, feature graphic, screenshots)
3. Test thoroughly on multiple devices
4. Review and remove unnecessary permissions
5. Enable ProGuard/R8 for release builds
6. Set up Google Play App Signing

✅ **COMPLETED SO FAR:**
- Dark Mode implementation
- Undo delete functionality
- Privacy policy document
- App descriptions (English & Arabic)
- Version updated to 2.0.0

🚧 **IN PROGRESS:**
- Localization (Phase 2)
- Speech-to-Text (Phase 3)
- Share/Export features (Phase 4)

---

**Last Updated:** December 12, 2024
