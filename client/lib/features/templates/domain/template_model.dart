import 'package:flutter/material.dart';

enum PhotoLayout {
  bottomLeft,
  bottomCenter,
  bottomRight,
  none,
  cutoutLarge,
}

class TemplatePalette {
  final Color bgColor;
  final Color pillBg;
  final Color pillText;
  final Color accent;
  final Color? frameColor;

  const TemplatePalette({
    required this.bgColor,
    required this.pillBg,
    required this.pillText,
    required this.accent,
    this.frameColor,
  });

  factory TemplatePalette.fromJson(Map<String, dynamic> json) {
    Color parseHex(String hex) {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16));
    }

    return TemplatePalette(
      bgColor: parseHex(json['bgColor'] ?? '#DFE6D6'),
      pillBg: parseHex(json['pillBg'] ?? '#FFFFFF'),
      pillText: parseHex(json['pillText'] ?? '#2B2623'),
      accent: parseHex(json['accent'] ?? '#8A6212'),
      frameColor: json['frameColor'] != null ? parseHex(json['frameColor']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    String toHex(Color c) => '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    return {
      'bgColor': toHex(bgColor),
      'pillBg': toHex(pillBg),
      'pillText': toHex(pillText),
      'accent': toHex(accent),
      if (frameColor != null) 'frameColor': toHex(frameColor!),
    };
  }
}

class TemplateText {
  final String text;
  final String style; // 'eyebrow', 'display', 'italic', 'body'
  final double x; // 0.0 to 1.0 (center x)
  final double y; // 0.0 to 1.0 (center y)
  final Color? color;
  final double? fontSize;
  final double? minFontSize;
  final double maxWidth; // 0.0 to 1.0
  final TextAlign align;

  const TemplateText({
    required this.text,
    required this.style,
    required this.x,
    required this.y,
    this.color,
    this.fontSize,
    this.minFontSize,
    this.maxWidth = 0.85,
    this.align = TextAlign.center,
  });

  factory TemplateText.fromJson(Map<String, dynamic> json) {
    Color? parseHex(String? hex) {
      if (hex == null) return null;
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16));
    }

    TextAlign parseAlign(String? alignStr) {
      switch (alignStr) {
        case 'left':
          return TextAlign.left;
        case 'right':
          return TextAlign.right;
        default:
          return TextAlign.center;
      }
    }

    return TemplateText(
      text: json['text'] as String,
      style: json['style'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      color: parseHex(json['color'] as String?),
      fontSize: json['fontSize'] != null ? (json['fontSize'] as num).toDouble() : null,
      minFontSize: json['minFontSize'] != null ? (json['minFontSize'] as num).toDouble() : null,
      maxWidth: json['maxWidth'] != null ? (json['maxWidth'] as num).toDouble() : 0.85,
      align: parseAlign(json['align'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    String? toHex(Color? c) =>
        c == null ? null : '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    return {
      'text': text,
      'style': style,
      'x': x,
      'y': y,
      if (color != null) 'color': toHex(color),
      if (fontSize != null) 'fontSize': fontSize,
      if (minFontSize != null) 'minFontSize': minFontSize,
      'maxWidth': maxWidth,
      'align': align.name,
    };
  }
}

class Template {
  final String id;
  final String category;
  final String title;
  final String festivalDate;
  final bool isPremium;
  final bool isActive;
  final int sortOrder;
  final TemplatePalette palette;
  final String? backgroundAsset;
  final List<TemplateText> texts;
  final List<PhotoLayout> photoLayouts;
  final PhotoLayout defaultLayout;
  final bool showInnerFrame;

  const Template({
    required this.id,
    required this.category,
    required this.title,
    required this.festivalDate,
    this.isPremium = false,
    this.isActive = true,
    this.sortOrder = 10,
    required this.palette,
    this.backgroundAsset,
    required this.texts,
    required this.photoLayouts,
    required this.defaultLayout,
    this.showInnerFrame = false,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    PhotoLayout parseLayout(String name) {
      return PhotoLayout.values.firstWhere(
        (e) => e.name == name,
        orElse: () => PhotoLayout.bottomLeft,
      );
    }

    final layoutsList = (json['photoLayouts'] as List<dynamic>?)
            ?.map((e) => parseLayout(e as String))
            .toList() ??
        [PhotoLayout.bottomLeft, PhotoLayout.bottomCenter, PhotoLayout.bottomRight, PhotoLayout.none];

    return Template(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      festivalDate: json['festivalDate'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? 10,
      palette: TemplatePalette.fromJson(json['palette'] as Map<String, dynamic>),
      backgroundAsset: json['backgroundAsset'] as String?,
      texts: (json['texts'] as List<dynamic>)
          .map((e) => TemplateText.fromJson(e as Map<String, dynamic>))
          .toList(),
      photoLayouts: layoutsList,
      defaultLayout: parseLayout(json['defaultLayout'] as String? ?? 'bottomLeft'),
      showInnerFrame: json['showInnerFrame'] as bool? ?? false,
    );
  }
}
