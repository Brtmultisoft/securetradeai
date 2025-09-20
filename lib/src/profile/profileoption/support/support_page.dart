import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rapidtradeai/data/api.dart';
import 'package:rapidtradeai/src/Service/assets_service.dart';
import 'package:rapidtradeai/src/widget/common_app_bar.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
	const SupportPage({Key? key}) : super(key: key);

	@override
	State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
	bool _loading = false;
	String? _supportEmail;
	String? _telegramBot;

	final Color _backgroundColor = const Color(0xFF1A2234);
	final Color _cardColor = const Color(0xFF1E293B);
	final Color _textColor = Colors.white;
	final Color _muted = Colors.white70;
	final Color _border = const Color(0xFF2A3A5A);
	final Color _accent =  TradingTheme.secondaryAccent;

	@override
	void initState() {
		super.initState();
		_fetchSupport();
	}

	Future<void> _fetchSupport() async {
		setState(() => _loading = true);
		try {
			final res = await http.get(Uri.parse(supportInfoUrl));
			if (res.statusCode == 200 && res.body.isNotEmpty) {
				final data = jsonDecode(res.body);
				if (data['status'] == 'success') {
					setState(() {
						_supportEmail = data['data']?['from_email']?.toString();
						_telegramBot = data['data']?['telegramlink']?.toString();
					});
				} else {
					showtoast(data['message'] ?? 'Failed to load support info', context);
				}
			} else {
				showtoast('Server Error: ${res.statusCode}', context);
			}
		} catch (e) {
			showtoast('Error: ${e.toString()}', context);
		} finally {
			setState(() => _loading = false);
		}
	}

	Future<void> _copy(String label, String value) async {
		await Clipboard.setData(ClipboardData(text: value));
		showtoast('$label copied', context);
	}

	Future<void> _openTelegram(String handleOrUrl) async {
		final String url = handleOrUrl.startsWith('http')
				? handleOrUrl
				: 'https://t.me/${handleOrUrl.replaceAll('@', '')}';
		final uri = Uri.parse(url);
		if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
			showtoast('Could not open Telegram', context);
		}
	}

	Widget _tile({required IconData icon, required String title, required String? value, required VoidCallback? onTap, required VoidCallback? onCopy}) {
		return Container(
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: _cardColor,
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: _border),
			),
			child: Row(
				children: [
					Container(
						padding: const EdgeInsets.all(8),
						decoration: BoxDecoration(
							color: _accent.withOpacity(0.2),
							borderRadius: BorderRadius.circular(8),
						),
						child: Icon(icon, color: _accent, size: 20),
					),
					const SizedBox(width: 16),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(title, style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.bold)),
								const SizedBox(height: 4),
								Text(value ?? 'Not set', style: TextStyle(color: _muted, fontSize: 14)),
							],
						),
					),
					Row(
						children: [
							IconButton(onPressed: value == null ? null : onCopy, icon: const Icon(Icons.copy), color: _accent),
							IconButton(onPressed: value == null ? null : onTap, icon: const Icon(Icons.open_in_new), color: _accent),
						],
					),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: _backgroundColor,
			appBar: CommonAppBar.basic(title: 'Support'),
			body: _loading
					? Center(child: CircularProgressIndicator(color: _accent))
					: Padding(
						padding: const EdgeInsets.all(16.0),
						child: Column(
							children: [
								_tile(
									icon: Icons.email,
									title: 'Support Email',
									value: _supportEmail,
									onCopy: _supportEmail == null ? null : () => _copy('Email', _supportEmail!),
									onTap: _supportEmail == null
										? null
										: () => launchUrl(Uri.parse('mailto:${_supportEmail!}')),
								),
								const SizedBox(height: 12),
								_tile(
									icon: Icons.telegram,
									title: 'Telegram Bot',
									value: _telegramBot,
									onCopy: _telegramBot == null ? null : () => _copy('Telegram', _telegramBot!),
									onTap: _telegramBot == null ? null : () => _openTelegram(_telegramBot!),
								),
							],
						),
					),
		);
	}
} 