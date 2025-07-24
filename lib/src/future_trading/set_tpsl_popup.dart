import 'package:flutter/material.dart';
import 'package:securetradeai/data/strings.dart';
import 'package:securetradeai/src/Service/assets_service.dart';
import 'package:securetradeai/src/Service/future_trading_service.dart';

class SetTpSlPopup extends StatefulWidget {
  const SetTpSlPopup({Key? key}) : super(key: key);

  @override
  State<SetTpSlPopup> createState() => _SetTpSlPopupState();
}

class _SetTpSlPopupState extends State<SetTpSlPopup> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final _positionIdController = TextEditingController();
  final _tpPriceController = TextEditingController();
  final _slPriceController = TextEditingController();

  @override
  void dispose() {
    _positionIdController.dispose();
    _tpPriceController.dispose();
    _slPriceController.dispose();
    super.dispose();
  }

  Future<void> _setTpSl() async {
    print('🎯 SET TP/SL - Starting validation...');

    if (_positionIdController.text.isEmpty) {
      print('❌ SET TP/SL - Position ID is empty');
      setState(() {
        _errorMessage = 'Position ID is required';
        _successMessage = null;
      });
      return;
    }

    final positionId = int.tryParse(_positionIdController.text);
    if (positionId == null) {
      print('❌ SET TP/SL - Invalid Position ID: ${_positionIdController.text}');
      setState(() {
        _errorMessage = 'Invalid Position ID';
        _successMessage = null;
      });
      return;
    }

    final tpPrice = _tpPriceController.text.isNotEmpty
        ? double.tryParse(_tpPriceController.text)
        : null;
    final slPrice = _slPriceController.text.isNotEmpty
        ? double.tryParse(_slPriceController.text)
        : null;

    print('🎯 SET TP/SL - Parsed values:');
    print('  Position ID: $positionId');
    print('  TP Price: $tpPrice');
    print('  SL Price: $slPrice');

    if (tpPrice == null && slPrice == null) {
      print('❌ SET TP/SL - No TP or SL price provided');
      setState(() {
        _errorMessage = 'At least one of TP Price or SL Price must be provided';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      print('🔄 SET TP/SL - Calling API...');
      print('  User ID: $commonuserId');
      print('  Position ID: $positionId');
      print('  TP Price: $tpPrice');
      print('  SL Price: $slPrice');

      final response = await FutureTradingService.setDualSideTpSl(
        userId: commonuserId,
        positionId: positionId,
        tpPrice: tpPrice,
        slPrice: slPrice,
      );

      print('📡 SET TP/SL - API Response received');
      print('  Response: $response');
      print('  Is Success: ${response?.isSuccess}');
      print('  Status: ${response?.status}');
      print('  Message: ${response?.message}');
      print('  Response Code: ${response?.responsecode}');

      if (response != null && response.isSuccess) {
        print('✅ SET TP/SL - Success! Response data:');
        print('  Position ID: ${response.data?.positionId}');
        print('  TP Price: ${response.data?.tpPrice}');
        print('  SL Price: ${response.data?.slPrice}');
        print('  Updated At: ${response.data?.updatedAt}');

        setState(() {
          _successMessage = 'TP/SL levels set successfully!\n'
              'Position ID: ${response.data?.positionId}\n'
              'TP Price: ${response.data?.tpPrice ?? 'Not set'}\n'
              'SL Price: ${response.data?.slPrice ?? 'Not set'}';
          _errorMessage = null;
          _isLoading = false;
        });

        // Clear form
        _positionIdController.clear();
        _tpPriceController.clear();
        _slPriceController.clear();
        print('✅ SET TP/SL - Form cleared');
      } else {
        print('❌ SET TP/SL - API Error:');
        print('  Status: ${response?.status}');
        print('  Message: ${response?.message}');
        print('  Response Code: ${response?.responsecode}');

        setState(() {
          _errorMessage = response?.message ?? 'Failed to set TP/SL levels';
          _successMessage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ SET TP/SL - Exception occurred: $e');
      setState(() {
        _errorMessage = 'Network error: $e';
        _successMessage = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: TradingTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: TradingTheme.primaryBorder.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _successMessage != null
                          ? _buildSuccessState()
                          : _buildFormContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TradingTheme.secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TradingTheme.warningColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit,
              color: TradingTheme.warningColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Set TP/SL Levels',
            style: TradingTypography.heading3,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: TradingTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TradingTheme.primaryAccent),
          SizedBox(height: 16),
          Text(
            'Setting TP/SL levels...',
            style: TradingTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: TradingTheme.errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Setting TP/SL',
            style: TradingTypography.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TradingTheme.primaryAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: TradingTheme.successColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'TP/SL Set Successfully',
            style: TradingTypography.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _successMessage!,
            style: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _successMessage = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradingTheme.secondaryBackground,
                    foregroundColor: TradingTheme.primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Set Another'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TradingTheme.primaryAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Position Details',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Position ID',
            _positionIdController,
            'Enter position ID (e.g., 456)',
            TextInputType.number,
            true,
          ),
          const SizedBox(height: 24),
          Text(
            'TP/SL Levels (Optional)',
            style: TradingTypography.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'You can set either Take Profit, Stop Loss, or both',
            style: TradingTypography.bodySmall.copyWith(
              color: TradingTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Take Profit Price',
            _tpPriceController,
            'Enter TP price (e.g., 60800.00)',
            TextInputType.numberWithOptions(decimal: true),
            false,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Stop Loss Price',
            _slPriceController,
            'Enter SL price (e.g., 59200.00)',
            TextInputType.numberWithOptions(decimal: true),
            false,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _setTpSl,
              style: ElevatedButton.styleFrom(
                backgroundColor: TradingTheme.warningColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Set TP/SL Levels',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
    TextInputType keyboardType,
    bool required,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TradingTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TradingTypography.bodyMedium.copyWith(
                  color: TradingTheme.errorColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TradingTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TradingTypography.bodyMedium.copyWith(
              color: TradingTheme.secondaryText,
            ),
            filled: true,
            fillColor: TradingTheme.secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: TradingTheme.primaryBorder.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: TradingTheme.primaryBorder.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: TradingTheme.primaryAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
