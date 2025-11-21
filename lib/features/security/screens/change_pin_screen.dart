import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/security_service.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final SecurityService _securityService = SecurityService();
  String _oldPin = '';
  String _newPin = '';
  String _confirmPin = '';
  int _step = 0; // 0: verify old, 1: enter new, 2: confirm new
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    setState(() {
      _errorMessage = '';
      
      if (_step == 0) {
        // Verify old PIN
        if (_oldPin.length < 4) {
          _oldPin += number;
          if (_oldPin.length == 4) {
            _verifyOldPin();
          }
        }
      } else if (_step == 1) {
        // Enter new PIN
        if (_newPin.length < 4) {
          _newPin += number;
          if (_newPin.length == 4) {
            Future.delayed(const Duration(milliseconds: 200), () {
              setState(() {
                _step = 2;
              });
            });
          }
        }
      } else {
        // Confirm new PIN
        if (_confirmPin.length < 4) {
          _confirmPin += number;
          if (_confirmPin.length == 4) {
            _validateAndSave();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _errorMessage = '';
      if (_step == 0) {
        if (_oldPin.isNotEmpty) {
          _oldPin = _oldPin.substring(0, _oldPin.length - 1);
        }
      } else if (_step == 1) {
        if (_newPin.isNotEmpty) {
          _newPin = _newPin.substring(0, _newPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      }
    });
  }

  Future<void> _verifyOldPin() async {
    final isValid = await _securityService.verifyPin(_oldPin);
    if (isValid) {
      setState(() {
        _step = 1;
      });
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN';
        _oldPin = '';
      });
    }
  }

  Future<void> _validateAndSave() async {
    if (_newPin == _confirmPin) {
      if (_newPin == _oldPin) {
        setState(() {
          _errorMessage = 'New PIN must be different';
          _confirmPin = '';
        });
        return;
      }
      
      await _securityService.changePin(_newPin);
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
      _newPin = '';
      _confirmPin = '';
      _step = 1;
      _errorMessage = '';
    });
  }

  String get _title {
    switch (_step) {
      case 0:
        return 'Enter current PIN';
      case 1:
        return 'Enter new PIN';
      case 2:
        return 'Confirm new PIN';
      default:
        return '';
    }
  }

  String get _subtitle {
    switch (_step) {
      case 0:
        return 'Verify your current PIN to continue';
      case 1:
        return 'Choose a new 4-digit PIN';
      case 2:
        return 'Re-enter your new PIN to confirm';
      default:
        return '';
    }
  }

  String get _currentPin {
    switch (_step) {
      case 0:
        return _oldPin;
      case 1:
        return _newPin;
      case 2:
        return _confirmPin;
      default:
        return '';
    }
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
          'Change PIN',
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
                      Icons.lock_reset,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Step Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _step == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _step >= index ? AppColors.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitle,
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
                      final isFilled = index < _currentPin.length;
                      
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
                  if (_step == 2) ...[
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
