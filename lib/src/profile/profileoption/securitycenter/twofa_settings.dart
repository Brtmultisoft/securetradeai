import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:securetradeai/data/api.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/widget/common_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_widget/barcode_widget.dart';

class TwoFASettings extends StatefulWidget {
	const TwoFASettings({Key? key}) : super(key: key);

	@override
	State<TwoFASettings> createState() => _TwoFASettingsState();
}

class _TwoFASettingsState extends State<TwoFASettings> {
	bool _loading = false;
	bool _enabled = false;
	String? _secret; // base32 secret returned by server
	String? _otpauth; // otpauth:// URL returned by server
	final TextEditingController _otpController = TextEditingController();

	final Color _backgroundColor = const Color(0xFF1E2329);
	final Color _cardColor = const Color(0xFF2B3139);
	final Color _primaryColor = const Color(0xFFF0B90B);
	final Color _textColor = const Color(0xFFEAECEF);
	final Color _borderColor = const Color(0xFF474D57);
	final Color _hintColor = const Color(0xFF848E9C);

	@override
	void initState() {
		super.initState();
		_fetchStatus();
	}

	Future<void> _fetchStatus() async {
		setState(() => _loading = true);
		try {
			final res = await http.get(Uri.parse(twofaStatusUrl));
			if (res.statusCode == 200 && res.body.isNotEmpty) {
				final data = jsonDecode(res.body);
				if (data['status'] == 'success') {
					setState(() {
						_enabled = data['data']?['enabled']?.toString() == '1' || data['data']?['enabled'] == true;
					});
				} else {
					showtoast(data['message'] ?? 'Failed to load 2FA status', context);
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

	Future<void> _initEnable() async {
		setState(() => _loading = true);
		try {
			final res = await http.get(Uri.parse(twofaInitUrl));
			if (res.statusCode == 200 && res.body.isNotEmpty) {
				final data = jsonDecode(res.body);
				if (data['status'] == 'success') {
					setState(() {
						_secret = data['data']?['secret']?.toString();
						_otpauth = data['data']?['otpauth']?.toString();
					});
				} else {
					showtoast(data['message'] ?? 'Failed to initialize 2FA', context);
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

	Future<void> _confirmEnable() async {
		final otp = _otpController.text.trim();
		if (otp.isEmpty) {
			showtoast('Please enter the 6-digit code', context);
			return;
		}
		setState(() => _loading = true);
		try {
			final res = await http.post(
				Uri.parse(twofaEnableUrl),
				headers: {
					'Content-Type': 'application/json',
					'Accept': 'application/json',
					'User-Agent': 'SecureTradeAI-Mobile-App',
				},
				body: jsonEncode({'otp': otp}),
			);
			if (res.statusCode == 200 && res.body.isNotEmpty) {
				final data = jsonDecode(res.body);
				if (data['status'] == 'success') {
					showtoast('2FA enabled successfully', context);
					setState(() {
						_enabled = true;
						_secret = null;
						_otpauth = null;
						_otpController.clear();
					});
				} else {
					showtoast(data['message'] ?? 'Failed to enable 2FA', context);
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

	Future<void> _disable() async {
		final otp = _otpController.text.trim();
		if (otp.isEmpty) {
			showtoast('Please enter the 6-digit code to disable', context);
			return;
		}
		setState(() => _loading = true);
		try {
			final res = await http.post(
				Uri.parse(twofaDisableUrl),
				headers: {
					'Content-Type': 'application/json',
					'Accept': 'application/json',
					'User-Agent': 'SecureTradeAI-Mobile-App',
				},
				body: jsonEncode({'otp': otp}),
			);
			if (res.statusCode == 200 && res.body.isNotEmpty) {
				final data = jsonDecode(res.body);
				if (data['status'] == 'success') {
					showtoast('2FA disabled successfully', context);
					setState(() {
						_enabled = false;
						_secret = null;
						_otpauth = null;
						_otpController.clear();
					});
				} else {
					showtoast(data['message'] ?? 'Failed to disable 2FA', context);
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

	Widget _statusChip() {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
			decoration: BoxDecoration(
				color: _enabled ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
				borderRadius: BorderRadius.circular(20),
				border: Border.all(color: _enabled ? Colors.green : Colors.red),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(_enabled ? Icons.verified_user : Icons.security,
						color: _enabled ? Colors.green : Colors.red, size: 16),
					const SizedBox(width: 6),
					Text(_enabled ? 'Enabled' : 'Disabled', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
				],
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: _backgroundColor,
			appBar: CommonAppBar.basic(title: 'Google 2FA'),
			body: _loading
					? Center(child: CircularProgressIndicator(color: _primaryColor))
					: SingleChildScrollView(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text('Two-Factor Authentication', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
										_statusChip(),
									],
								),
								const SizedBox(height: 12),
								Text(
									'Use Google Authenticator or any TOTP app to secure your account.',
									style: TextStyle(color: _hintColor),
								),
								const SizedBox(height: 16),

								if (!_enabled && _otpauth == null) ...[
									Container(
										width: double.infinity,
										padding: const EdgeInsets.all(16),
										decoration: BoxDecoration(
											color: _cardColor,
											borderRadius: BorderRadius.circular(12),
											border: Border.all(color: _borderColor),
										),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text('Step 1: Generate QR Code', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
												const SizedBox(height: 8),
												Text('Tap the button below to generate your Google Authenticator QR code.', style: TextStyle(color: _hintColor)),
												const SizedBox(height: 12),
												ElevatedButton(
													style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: _backgroundColor),
													onPressed: _initEnable,
													child: const Text('Generate QR'),
												),
											],
										),
									),
								],

								if (_otpauth != null) ...[
									const SizedBox(height: 16),
									Container(
										width: double.infinity,
										padding: const EdgeInsets.all(16),
										decoration: BoxDecoration(
											color: _cardColor,
											borderRadius: BorderRadius.circular(12),
											border: Border.all(color: _borderColor),
										),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.center,
											children: [
												Text('Step 2: Scan this QR in Google Authenticator', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
												const SizedBox(height: 12),
												Container(
													padding: const EdgeInsets.all(12),
													decoration: BoxDecoration(
														color: Colors.white,
														borderRadius: BorderRadius.circular(12),
													),
													child: BarcodeWidget(
														barcode: Barcode.qrCode(),
														data: _otpauth!,
														width: 220,
														height: 220,
													),
												),
												const SizedBox(height: 8),
												if (_secret != null)
													Text('Secret: $_secret', style: TextStyle(color: _hintColor)),
												const SizedBox(height: 12),
												TextField(
													controller: _otpController,
													keyboardType: TextInputType.number,
													maxLength: 6,
													style: TextStyle(color: _textColor),
													decoration: InputDecoration(
														counterText: '',
														filled: true,
														fillColor: _cardColor,
														labelText: 'Enter 6-digit code',
														labelStyle: TextStyle(color: _hintColor),
														enabledBorder: OutlineInputBorder(
															borderSide: BorderSide(color: _borderColor),
															borderRadius: BorderRadius.circular(10),
														),
														focusedBorder: OutlineInputBorder(
															borderSide: BorderSide(color: _primaryColor),
															borderRadius: BorderRadius.circular(10),
														),
													),
												),
												const SizedBox(height: 8),
												Row(
													children: [
														Expanded(
															child: ElevatedButton(
																style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
																onPressed: _confirmEnable,
																child: const Text('Enable 2FA'),
															),
														),
														const SizedBox(width: 10),
														Expanded(
															child: OutlinedButton(
																style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
																onPressed: () {
																	setState(() {
																		_otpauth = null;
																		_secret = null;
																		_otpController.clear();
																	});
																},
																child: const Text('Cancel'),
															),
														),
													],
												),
											],
										),
									),
								],

								if (_enabled) ...[
									const SizedBox(height: 16),
									Container(
										width: double.infinity,
										padding: const EdgeInsets.all(16),
										decoration: BoxDecoration(
											color: _cardColor,
											borderRadius: BorderRadius.circular(12),
											border: Border.all(color: _borderColor),
										),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text('Disable 2FA', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
												const SizedBox(height: 8),
												Text('Enter the current 6-digit code from your authenticator to disable.', style: TextStyle(color: _hintColor)),
												const SizedBox(height: 12),
												TextField(
													controller: _otpController,
													keyboardType: TextInputType.number,
													maxLength: 6,
													style: TextStyle(color: _textColor),
													decoration: InputDecoration(
														counterText: '',
														filled: true,
														fillColor: _cardColor,
														labelText: '6-digit code',
														labelStyle: TextStyle(color: _hintColor),
														enabledBorder: OutlineInputBorder(
															borderSide: BorderSide(color: _borderColor),
															borderRadius: BorderRadius.circular(10),
														),
														focusedBorder: OutlineInputBorder(
															borderSide: BorderSide(color: _primaryColor),
															borderRadius: BorderRadius.circular(10),
														),
													),
												),
												const SizedBox(height: 8),
												ElevatedButton(
													style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
													onPressed: _disable,
													child: const Text('Disable 2FA'),
												),
											],
										),
									),
								],
							],
						),
					),
		);
	}
} 