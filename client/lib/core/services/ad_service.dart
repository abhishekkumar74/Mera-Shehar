import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_service.dart';

enum AdPlacement {
  homeNative,
  tyoharNative,
  shareInterstitial,
}

class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  bool _initialized = false;
  bool _canRequestAds = true;
  bool _adsEnabled = true;
  int _nativeAdEveryN = 8;
  int _interstitialEveryNShares = 3;

  DateTime? _lastInterstitialShownAt;
  InterstitialAd? _preloadedInterstitial;
  bool _isPreloadingInterstitial = false;

  final Map<AdPlacement, int> _retryCount = {};

  // Google Test Ad Unit IDs
  static const String _testNativeId = 'ca-app-pub-3940256099942544/2247696110';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  bool get adsEnabled => _adsEnabled && _canRequestAds;
  int get nativeAdEveryN => _nativeAdEveryN;
  int get interstitialEveryNShares => _interstitialEveryNShares;
  bool get isInterstitialLoaded => _preloadedInterstitial != null;

  void updateRemoteConfigSettings({
    bool adsEnabled = true,
    int nativeAdEveryN = 8,
    int interstitialEveryNShares = 3,
  }) {
    _adsEnabled = adsEnabled;
    _nativeAdEveryN = nativeAdEveryN;
    _interstitialEveryNShares = interstitialEveryNShares;
  }

  String _getAdUnitId(AdPlacement placement) {
    // HARD GUARD: Debug mode ALWAYS uses official Google test IDs
    if (kDebugMode) {
      switch (placement) {
        case AdPlacement.homeNative:
        case AdPlacement.tyoharNative:
          return _testNativeId;
        case AdPlacement.shareInterstitial:
          return _testInterstitialId;
      }
    }

    // In production, fallback to test IDs if environment defines are missing
    switch (placement) {
      case AdPlacement.homeNative:
        return const String.fromEnvironment('ADMOB_HOME_NATIVE_ID', defaultValue: _testNativeId);
      case AdPlacement.tyoharNative:
        return const String.fromEnvironment('ADMOB_TYOHAR_NATIVE_ID', defaultValue: _testNativeId);
      case AdPlacement.shareInterstitial:
        return const String.fromEnvironment('ADMOB_SHARE_INTERSTITIAL_ID', defaultValue: _testInterstitialId);
    }
  }

  Future<void> initializeAfterFirstFrame() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final params = ConsentRequestParameters(
        consentDebugSettings: kDebugMode
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      );

      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          _canRequestAds = await ConsentInformation.instance.canRequestAds();
          if (_canRequestAds) {
            await MobileAds.instance.initialize();
          }
        },
        (FormError error) {
          debugPrint('[AdService] Consent info error: ${error.message}');
        },
      );
    } catch (e) {
      debugPrint('[AdService] Initialization error: $e');
    }
  }

  /// Pure function eligibility logic for Interstitial ads
  static bool checkInterstitialEligibility({
    required bool adsEnabled,
    required bool canRequestAds,
    required int sessionCount,
    required int sharesTotal,
    required int interstitialEveryNShares,
    required DateTime? lastInterstitialShownAt,
    required DateTime now,
    required bool isLoaded,
  }) {
    if (!adsEnabled || !canRequestAds) return false;
    if (sessionCount < 2) return false;
    if (sharesTotal <= 0 || sharesTotal % interstitialEveryNShares != 0) return false;
    if (!isLoaded) return false;

    if (lastInterstitialShownAt != null) {
      final secondsPassed = now.difference(lastInterstitialShownAt).inSeconds;
      if (secondsPassed < 90) return false;
    }

    return true;
  }

  Future<bool> isInterstitialEligibleNow() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionCount = prefs.getInt('session_count') ?? 1;
    final sharesTotal = prefs.getInt('shares_total') ?? 0;

    return checkInterstitialEligibility(
      adsEnabled: _adsEnabled,
      canRequestAds: _canRequestAds,
      sessionCount: sessionCount,
      sharesTotal: sharesTotal,
      interstitialEveryNShares: _interstitialEveryNShares,
      lastInterstitialShownAt: _lastInterstitialShownAt,
      now: DateTime.now(),
      isLoaded: isInterstitialLoaded,
    );
  }

  Future<void> preloadInterstitial() async {
    if (!adsEnabled || _preloadedInterstitial != null || _isPreloadingInterstitial) return;
    _isPreloadingInterstitial = true;

    final unitId = _getAdUnitId(AdPlacement.shareInterstitial);

    try {
      await InterstitialAd.load(
        adUnitId: unitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _preloadedInterstitial = ad;
            _isPreloadingInterstitial = false;
            _retryCount[AdPlacement.shareInterstitial] = 0;

            ad.onPaidEvent = (ad, valueMicros, currencyCode, precision) {
              analyticsService.logEvent('ad_paid', {
                'placement': 'shareInterstitial',
                'value_micros': valueMicros,
                'currency_code': currencyCode,
              });
            };
          },
          onAdFailedToLoad: (error) {
            _isPreloadingInterstitial = false;
            analyticsService.logEvent('ad_failed', {
              'placement': 'shareInterstitial',
              'error_code': error.code,
            });
            _scheduleRetry(AdPlacement.shareInterstitial, () => preloadInterstitial());
          },
        ),
      );
    } catch (_) {
      _isPreloadingInterstitial = false;
    }
  }

  Future<void> showInterstitialIfEligible({required VoidCallback onComplete}) async {
    final eligible = await isInterstitialEligibleNow();
    if (!eligible || _preloadedInterstitial == null) {
      onComplete();
      return;
    }

    final ad = _preloadedInterstitial!;
    _preloadedInterstitial = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastInterstitialShownAt = DateTime.now();
        analyticsService.logEvent('ad_impression', {'placement': 'shareInterstitial'});
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        analyticsService.logEvent('ad_failed', {
          'placement': 'shareInterstitial',
          'error_code': error.code,
        });
        onComplete();
      },
    );

    ad.show();
  }

  NativeAd createNativeAd({
    required AdPlacement placement,
    required Function(NativeAd) onAdLoaded,
    required Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    final unitId = _getAdUnitId(placement);

    final nativeAd = NativeAd(
      adUnitId: unitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: const Color(0xFFFFFFFF),
        cornerRadius: 16,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF2B2623),
          backgroundColor: const Color(0xFFC9A04A),
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF2B2623),
          style: NativeTemplateFontStyle.normal,
          size: 14,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          analyticsService.logEvent('ad_impression', {'placement': placement.name});
          onAdLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          analyticsService.logEvent('ad_failed', {
            'placement': placement.name,
            'error_code': error.code,
          });
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
        onPaidEvent: (ad, valueMicros, currencyCode, precision) {
          analyticsService.logEvent('ad_paid', {
            'placement': placement.name,
            'value_micros': valueMicros,
            'currency_code': currencyCode,
          });
        },
      ),
    );

    nativeAd.load();
    return nativeAd;
  }

  void _scheduleRetry(AdPlacement placement, VoidCallback retryAction) {
    final current = _retryCount[placement] ?? 0;
    if (current >= 2) return; // Retry at most twice

    _retryCount[placement] = current + 1;
    Timer(const Duration(seconds: 60), retryAction);
  }
}

final adService = AdService.instance;
