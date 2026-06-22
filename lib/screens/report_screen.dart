import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../common/theme.dart';

enum _ResponseType { html, table, keyValue, list, plain }

// Field names that may carry a photo URL
const _photoKeys = {
  'photourl', 'photo_url', 'photo', 'profile', 'profile_photo',
  'image', 'image_url', 'picture', 'avatar', 'pic', 'passport',
  'passport_photo', 'student_photo', 'studentphoto',
};

class ReportScreen extends StatefulWidget {
  final String title;
  final dynamic data;

  const ReportScreen({super.key, required this.title, required this.data});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final dynamic _parsed;   // always decoded — never a raw JSON string
  late final _ResponseType _type;
  late final String? _photoUrl;
  late final String _htmlContent;
  WebViewController? _webController;
  bool _webLoading = true;

  @override
  void initState() {
    super.initState();
    _parsed   = _decode(widget.data);
    _photoUrl = _extractPhoto(_parsed);
    _type     = _detect(_parsed);
    _htmlContent = _type == _ResponseType.html ? _wrapHtml(_parsed.toString()) : '';

    if (_type == _ResponseType.html) {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFF0F4FF))
        ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) => setState(() => _webLoading = false),
        ))
        ..loadHtmlString(_htmlContent);
    }
  }

  // Recursively decode JSON strings so we never display raw JSON to the user
  dynamic _decode(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map || raw is List) return raw;
    final s = raw.toString().trim();
    if ((s.startsWith('{') && s.endsWith('}')) ||
        (s.startsWith('[') && s.endsWith(']'))) {
      try { return jsonDecode(s); } catch (_) {}
    }
    return raw;
  }

  // Find a photo URL field anywhere in the top-level map
  String? _extractPhoto(dynamic data) {
    if (data is! Map) return null;
    for (final entry in data.entries) {
      final key = entry.key.toString().toLowerCase().replaceAll(' ', '_');
      if (_photoKeys.contains(key)) {
        final val = entry.value?.toString().trim() ?? '';
        if (val.isNotEmpty && (val.startsWith('http') || val.startsWith('/'))) {
          return val;
        }
      }
    }
    return null;
  }

  _ResponseType _detect(dynamic data) {
    if (data == null) return _ResponseType.plain;
    final s = data.toString().trimLeft();
    if (s.startsWith('<') ||
        s.toLowerCase().contains('<html') ||
        s.toLowerCase().contains('<table') ||
        s.toLowerCase().contains('<div')) {
      return _ResponseType.html;
    }
    if (data is Map) {
      if (data.values.any((v) => v is Map || v is List)) return _ResponseType.table;
      return _ResponseType.keyValue;
    }
    if (data is List) return _ResponseType.list;
    return _ResponseType.plain;
  }

  // ─── HTML helpers ─────────────────────────────────────────────────────────

  String _wrapHtml(String raw) {
    if (raw.toLowerCase().contains('<html')) return _injectStyles(raw);
    return '''<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0">
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:-apple-system,'Segoe UI',Roboto,Arial,sans-serif;font-size:14px;background:#f0f4ff;color:#1a1a2e;padding:16px;line-height:1.6}
h1,h2,h3,h4{color:#1565c0;margin:12px 0 8px;font-weight:600}
h1{font-size:20px}h2{font-size:17px}h3{font-size:15px}
table{width:100%;border-collapse:collapse;background:#fff;border-radius:12px;overflow:hidden;margin:12px 0;box-shadow:0 2px 12px rgba(21,101,192,.10)}
thead tr{background:linear-gradient(135deg,#1565c0,#0288d1);color:#fff}
thead th{padding:11px 14px;text-align:left;font-size:12px;font-weight:600;letter-spacing:.4px;text-transform:uppercase}
tbody tr{border-bottom:1px solid #e5e7eb}
tbody tr:last-child{border-bottom:none}
tbody tr:nth-child(even){background:#f8faff}
tbody td{padding:10px 14px;font-size:13px;color:#1a1a2e;vertical-align:top}
img{max-width:100%;border-radius:10px;margin:8px 0}
.card{background:#fff;border-radius:14px;padding:16px;margin:10px 0;box-shadow:0 2px 12px rgba(21,101,192,.10)}
.badge{display:inline-block;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600}
.badge-success{background:#dcfce7;color:#166534}
.badge-danger{background:#fee2e2;color:#991b1b}
.badge-info{background:#dbeafe;color:#1e40af}
.badge-warning{background:#fef9c3;color:#854d0e}
p{margin:6px 0}strong{color:#1565c0}
hr{border:none;border-top:1px solid #e5e7eb;margin:12px 0}
ul,ol{padding-left:20px;margin:8px 0}li{margin:4px 0}
</style></head><body>$raw</body></html>''';
  }

  String _injectStyles(String html) {
    const style = '<style>'
        'body{font-family:-apple-system,"Segoe UI",Roboto,Arial,sans-serif;font-size:14px;background:#f0f4ff;padding:16px;color:#1a1a2e}'
        'table{width:100%;border-collapse:collapse;background:#fff;border-radius:12px;overflow:hidden;margin:12px 0}'
        'thead tr{background:linear-gradient(135deg,#1565c0,#0288d1);color:#fff}'
        'thead th{padding:11px 14px;text-align:left;font-size:12px;text-transform:uppercase}'
        'tbody tr{border-bottom:1px solid #e5e7eb}'
        'tbody tr:nth-child(even){background:#f8faff}'
        'tbody td{padding:10px 14px;font-size:13px}'
        'h1,h2,h3{color:#1565c0;margin:10px 0 6px}'
        'img{max-width:100%;border-radius:10px}'
        '</style>';
    return html.contains('</head>')
        ? html.replaceFirst('</head>', '$style</head>')
        : '$style$html';
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatKey(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '')
      .join(' ');

  bool _isPhotoKey(String key) =>
      _photoKeys.contains(key.toLowerCase().replaceAll(' ', '_'));

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied to clipboard', style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title = widget.title.replaceAll('_', ' ');
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
        actions: [
          if (_type != _ResponseType.html)
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: 'Copy',
              onPressed: () => _copyToClipboard(_parsed.toString()),
            ),
        ],
      ),
      body: _type == _ResponseType.html
          ? _buildHtmlView()
          : _buildScrollable(title),
    );
  }

  // ─── HTML WebView ─────────────────────────────────────────────────────────

  Widget _buildHtmlView() => Stack(children: [
        WebViewWidget(controller: _webController!),
        if (_webLoading)
          Container(
            color: const Color(0xFFF0F4FF),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(color: AppTheme.primary),
                const SizedBox(height: 14),
                Text('Loading...', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
              ]),
            ),
          ),
      ]);

  // ─── Scrollable content ───────────────────────────────────────────────────

  Widget _buildScrollable(String title) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Photo at the very top
        if (_photoUrl != null) ...[
          _buildPhotoCard(_photoUrl!),
          const SizedBox(height: 16),
        ],
        _buildHeader(title),
        const SizedBox(height: 16),
        _buildContent().animate(delay: 150.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08),
        const SizedBox(height: 24),
        _buildDoneButton(),
      ]),
    );
  }

  // ─── Photo card ───────────────────────────────────────────────────────────

  Widget _buildPhotoCard(String url) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )],
          border: Border.all(color: AppTheme.primary.withOpacity(0.25), width: 3),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 120,
              height: 120,
              color: AppTheme.primary.withOpacity(0.08),
              child: const Icon(Icons.person_rounded, size: 56, color: AppTheme.primary),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 120,
              height: 120,
              color: AppTheme.primary.withOpacity(0.08),
              child: const Icon(Icons.broken_image_rounded, size: 48, color: AppTheme.primary),
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).fadeIn(duration: 300.ms);
  }

  // ─── Header banner ────────────────────────────────────────────────────────

  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.description_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(_typeLabel(),
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
        ])),
      ]),
    ).animate().fadeIn().slideY(begin: -0.05);
  }

  String _typeLabel() {
    switch (_type) {
      case _ResponseType.table:    return 'Structured data';
      case _ResponseType.keyValue: return 'Student record';
      case _ResponseType.list:     return '${(_parsed as List).length} items';
      default:                     return 'Response';
    }
  }

  Widget _buildContent() {
    switch (_type) {
      case _ResponseType.html:     return const SizedBox.shrink();
      case _ResponseType.table:    return _buildNestedTable(_parsed as Map);
      case _ResponseType.keyValue: return _buildKeyValueCard(_parsed as Map);
      case _ResponseType.list:     return _buildListWidget(_parsed as List);
      default:                     return _buildPlainCard(_parsed.toString());
    }
  }

  // ─── Key-Value card ───────────────────────────────────────────────────────

  Widget _buildKeyValueCard(Map data) {
    // Skip photo fields — already shown at the top
    final entries = data.entries
        .where((e) =>
            !_isPhotoKey(e.key.toString()) &&
            e.value != null &&
            e.value.toString().trim().isNotEmpty)
        .toList();

    if (entries.isEmpty) {
      return _buildPlainCard('No additional details available.');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: entries.asMap().entries.map((entry) {
          final idx   = entry.key;
          final e     = entry.value;
          final isLast = idx == entries.length - 1;
          final value  = e.value.toString().trim();
          final isLong = value.length > 55;

          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: isLong
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_formatKey(e.key.toString()),
                          style: GoogleFonts.poppins(
                              fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Text(value,
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                      ),
                    ])
                  : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        flex: 4,
                        child: Text(_formatKey(e.key.toString()),
                            style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: Text(value,
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ),
                    ]),
            ),
            if (!isLast) Divider(height: 1, color: AppTheme.divider, indent: 18, endIndent: 18),
          ]);
        }).toList(),
      ),
    );
  }

  // ─── Nested sections (Map with nested Maps/Lists) ─────────────────────────

  Widget _buildNestedTable(Map data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries
          .where((e) => !_isPhotoKey(e.key.toString()))
          .map((entry) {
        final key   = _formatKey(entry.key.toString());
        final value = entry.value;

        if (value is List && value.isNotEmpty && value.first is Map) {
          return _section(key, _buildDataTable(value));
        }
        if (value is Map) {
          return _section(key, _buildKeyValueCard(value));
        }
        if (value is List) {
          return _section(key, _buildListWidget(value));
        }
        // Single value
        if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();
        return _section(
          key,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Text(value.toString(),
                style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary)),
          ),
        );
      }).toList(),
    );
  }

  Widget _section(String title, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ),
          child,
          const SizedBox(height: 20),
        ],
      );

  // ─── DataTable for List<Map> ──────────────────────────────────────────────

  Widget _buildDataTable(List rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final headers = (rows.first as Map).keys.map((k) => k.toString()).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(AppTheme.primary),
            headingTextStyle: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            dataTextStyle: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary),
            columnSpacing: 20,
            horizontalMargin: 16,
            columns: headers.map((h) => DataColumn(label: Text(_formatKey(h)))).toList(),
            rows: rows.asMap().entries.map((entry) {
              final row = entry.value as Map;
              return DataRow(
                color: MaterialStateProperty.resolveWith((_) =>
                    entry.key.isEven ? Colors.white : const Color(0xFFF8FAFF)),
                cells: headers
                    .map((h) => DataCell(Text(row[h]?.toString() ?? '—',
                        style: GoogleFonts.poppins(fontSize: 12))))
                    .toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── List ─────────────────────────────────────────────────────────────────

  Widget _buildListWidget(List items) {
    if (items.isNotEmpty && items.first is Map) return _buildDataTable(items);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                radius: 16,
                child: Text('${entry.key + 1}',
                    style: GoogleFonts.poppins(
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ),
              title: Text(entry.value.toString(),
                  style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textPrimary)),
            ),
            if (!isLast) Divider(height: 1, color: AppTheme.divider, indent: 56, endIndent: 16),
          ]);
        }).toList(),
      ),
    );
  }

  // ─── Plain text ───────────────────────────────────────────────────────────

  Widget _buildPlainCard(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
        ),
        child: SelectableText(text,
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary, height: 1.7)),
      );

  // ─── Done button ──────────────────────────────────────────────────────────

  Widget _buildDoneButton() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: Text('Done',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15);
}
