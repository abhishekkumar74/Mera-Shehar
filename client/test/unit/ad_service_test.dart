import 'package:flutter_test/flutter_test.dart';
import 'package:roz/core/services/ad_service.dart';

void main() {
  group('AdService Interstitial Eligibility Tests', () {
    final now = DateTime(2026, 10, 2, 12, 0, 0);

    test('First app session (sessionCount = 1) is ineligible for interstitial', () {
      final eligible = AdService.checkInterstitialEligibility(
        adsEnabled: true,
        canRequestAds: true,
        sessionCount: 1,
        sharesTotal: 3,
        interstitialEveryNShares: 3,
        lastInterstitialShownAt: null,
        now: now,
        isLoaded: true,
      );

      expect(eligible, false);
    });

    test('Shares total not divisible by N is ineligible', () {
      final eligible = AdService.checkInterstitialEligibility(
        adsEnabled: true,
        canRequestAds: true,
        sessionCount: 2,
        sharesTotal: 4,
        interstitialEveryNShares: 3,
        lastInterstitialShownAt: null,
        now: now,
        isLoaded: true,
      );

      expect(eligible, false);
    });

    test('Shown less than 90 seconds ago is ineligible', () {
      final lastShown = now.subtract(const Duration(seconds: 45));
      final eligible = AdService.checkInterstitialEligibility(
        adsEnabled: true,
        canRequestAds: true,
        sessionCount: 2,
        sharesTotal: 6,
        interstitialEveryNShares: 3,
        lastInterstitialShownAt: lastShown,
        now: now,
        isLoaded: true,
      );

      expect(eligible, false);
    });

    test('Disabled ads or missing load state is ineligible', () {
      final eligibleAdsDisabled = AdService.checkInterstitialEligibility(
        adsEnabled: false,
        canRequestAds: true,
        sessionCount: 2,
        sharesTotal: 3,
        interstitialEveryNShares: 3,
        lastInterstitialShownAt: null,
        now: now,
        isLoaded: true,
      );

      final eligibleNotLoaded = AdService.checkInterstitialEligibility(
        adsEnabled: true,
        canRequestAds: true,
        sessionCount: 2,
        sharesTotal: 3,
        interstitialEveryNShares: 3,
        lastInterstitialShownAt: null,
        now: now,
        isLoaded: false,
      );

      expect(eligibleAdsDisabled, false);
      expect(eligibleNotLoaded, false);
    });

    test('Valid session, shares, time, and loaded status is eligible', () {
      final lastShown = now.subtract(const Duration(seconds: 120));
      final eligible = AdService.checkInterstitialEligibility(
        adsEnabled: true,
        canRequestAds: true,
        sessionCount: 2,
        sharesTotal: 3,
        interstitialEveryNShares: 3,
        lastInterstitialShownAt: lastShown,
        now: now,
        isLoaded: true,
      );

      expect(eligible, true);
    });
  });

  group('Grid Chunking Logic Tests', () {
    test('Chunks templates by nativeAdEveryN correctly', () {
      final list = List.generate(20, (index) => 'item_$index');
      const chunkSize = 8;

      final chunks = <List<String>>[];
      for (var i = 0; i < list.length; i += chunkSize) {
        final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
        chunks.add(list.sublist(i, end));
      }

      expect(chunks.length, 3);
      expect(chunks[0].length, 8);
      expect(chunks[1].length, 8);
      expect(chunks[2].length, 4);
    });
  });
}
