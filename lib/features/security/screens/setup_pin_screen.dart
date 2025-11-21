import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/security_service.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final SecurityService _securityService = SecurityService();
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    setState(() {
      _errorMessage = '';
      
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _validateAndSave();
          }
        }
      } else {
        if (_pin.length < 4) {
          _pin += number;
          if (_pin.length == 4) {
            // Move to confirmation
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() {
                _isConfirming = true;
              });
            });
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _errorMessage = '';
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _validateAndSave() async {
    if (_pin == _confirmPin) {
      await _securityService.setPin(_pin);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        _errorMessage = 'PINs do not match';
        _confirmPin = '';
      });
    }
  }

  void _reset() {
    setState(() {
      _pin = '';
      _confirmPin = '';
      _isConfirming = false;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set up PIN',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isConfirming ? Icons.lock_outline : Icons.lock_open,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _isConfirming ? 'Confirm your PIN' : 'Enter a 4-digit PIN',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConfirming
                        ? 'Re-enter your PIN to confirm'
                        : 'This PIN will be used to secure your app',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // PIN Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final currentPin = _isConfirming ? _confirmPin : _pin;
                      final isFilled = index < currentPin.length;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isFilled ? AppColors.primary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFilled ? AppColors.primary : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),

                  // Error Message
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Reset Button
                  if (_isConfirming) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _reset,
                      child: Text(
                        'Start over',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Number Pad
            _buildNumberPad(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 16),

          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 16),

          // Row 4: Empty, 0, Backspace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70, height: 70), // Empty space
              _buildNumberButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
