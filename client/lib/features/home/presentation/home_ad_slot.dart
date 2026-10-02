import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/services/ad_service.dart';
import '../../../core/tokens/app_tokens.dart';

class HomeAdSlot extends StatefulWidget {
  const HomeAdSlot({super.key});

  @override
  State<HomeAdSlot> createState() => _HomeAdSlotState();
}

class _HomeAdSlotState extends State<HomeAdSlot> {
  NativeAd? _nativeAd;
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!adService.adsEnabled) return;

    _nativeAd = adService.createNativeAd(
      placement: AdPlacement.homeNative,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _adLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        if (mounted) {
          setState(() {
            _adLoaded = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!adService.adsEnabled || !_adLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: AppTokens.space24),
      height: 90,
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusTile),
        border: Border.all(color: AppTokens.border, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusTile),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}
