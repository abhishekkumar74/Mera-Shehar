/// Central copy deck containing all user-facing strings for Mera Shehar.
/// Strictly follows master.md copy deck rules (no "successfully", "please", "unlock", "premium experience").
abstract class AppStrings {
  static const String appName = 'Mera Shehar';

  // Navigation Tabs
  static const String tabHome = 'Home';
  static const String tabTyohar = 'Tyohar';
  static const String tabSaved = 'Saved';
  static const String tabProfile = 'Profile';

  // Onboarding (S1)
  static const String onboardingHeading = 'Apna card, apne naam se';
  static const String onboardingSub = 'Ek baar photo aur naam daalo. Baaki roz ka card ready milega.';
  static const String onboardingPhotoLabel = 'Photo chunein';
  static const String onboardingPhotoCaption = 'Passport ya profile photo';
  static const String onboardingNameLabel = 'Aapka naam';
  static const String onboardingButton = 'Shuru karein';
  static const String onboardingTimeNotice = 'Sirf 20 second lagenge';
  static const String onboardingPrivacyNotice = 'Aapka photo sirf aapke phone mein rehta hai.';
  static const String onboardingTermsConsent = 'Aage badhkar aap Privacy Policy aur Terms se sahmat hote hain.';
  static const String onboardingErrPhoto = 'Photo chunein';
  static const String onboardingErrName = 'Naam daalo';

  // Home (S2)
  static const String homeGreetingPrefix = 'Namaste';
  static const String homeUpcomingSectionTitle = 'Aane wale tyohar';
  static const String homeSeeAll = 'Sab dekho';
  static const String homeButtonStatus = 'Status lagao';
  static const String homeButtonEdit = 'Badlo';

  // Editor (S4)
  static const String editorPhotoLayoutHeader = 'Photo kahan lage';
  static const String editorButtonStatus = 'Status';
  static const String editorButtonShare = 'Share';

  // Share Success (S5)
  static const String shareSuccessTitle = 'Card tayyar hai';
  static const String shareSuccessSub = 'Status par lagao, dost dekhenge.';
  static const String shareSuccessPrimary = 'Ek aur card banao';
  static const String shareSuccessSecondary = 'Home par jao';

  // Saved (S7)
  static const String savedEmptyTitle = 'Abhi koi card save nahi kiya';
  static const String savedEmptyButton = 'Tyohar dekho';

  // Profile (S6)
  static const String profileTitle = 'Profile';
  static const String profileShareApp = 'Dost ko bhejo';
  static const String profilePrivacy = 'Privacy Policy';
  static const String profileTerms = 'Terms & Conditions';

  // Errors
  static const String errOffline = 'Internet nahi hai. Card phir bhi ban sakta hai.';
  static const String errGeneric = 'Card nahi ban paaya. Dobara try karo.';
  static const String phase0Placeholder = 'Phase 0 placeholder';
}
