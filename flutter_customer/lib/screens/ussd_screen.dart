import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';

class USSDScreen extends StatefulWidget {
  const USSDScreen({super.key});

  @override
  State<USSDScreen> createState() => _USSDScreenState();
}

class _USSDScreenState extends State<USSDScreen> {
  final _supabaseService = SupabaseService();
  String _currentMenu = 'main';
  String _displayText = '';
  List<String> _menuHistory = [];
  Map<String, dynamic>? _queueData;
  
  // Input for manual entry
  String _nameInput = '';
  String _phoneInput = '';
  bool _isInputMode = false;
  String _inputType = '';

  @override
  void initState() {
    super.initState();
    _showMainMenu();
  }

  void _showMainMenu() {
    setState(() {
      _displayText = '''
━━━━━━━━━━━━━━━━━━
   SMARTQUEUE
━━━━━━━━━━━━━━━━━━

Welcome to SmartQueue
Virtual Queue System

[1] Join Queue
[2] Check Status
[3] About
[0] Exit

━━━━━━━━━━━━━━━━━━
Enter option:''';
      _currentMenu = 'main';
    });
  }

  void _showJoinMenu() {
    setState(() {
      _displayText = '''
━━━━━━━━━━━━━━━━━━
   JOIN QUEUE
━━━━━━━━━━━━━━━━━━

Sample College Clinic
Avg. Service: 15 min

[1] Enter Name
[9] Back
[0] Main Menu

━━━━━━━━━━━━━━━━━━
Enter option:''';
      _currentMenu = 'join';
    });
  }

  void _showCheckStatusMenu() {
    setState(() {
      _displayText = '''
━━━━━━━━━━━━━━━━━━
  CHECK STATUS
━━━━━━━━━━━━━━━━━━

${_queueData != null ? '''
Name: ${_queueData!['customer_name']}
Position: ${_queueData!['position']}
Status: ${_queueData!['status']}
Wait Time: ${_queueData!['estimated_wait_time']} min

${_queueData!['status'] == 'serving' ? '⚠ IT\'S YOUR TURN! ⚠' : ''}
''' : 'No active queue found.'}

[9] Back
[0] Main Menu

━━━━━━━━━━━━━━━━━━
Enter option:''';
      _currentMenu = 'status';
    });
  }

  void _showAboutMenu() {
    setState(() {
      _displayText = '''
━━━━━━━━━━━━━━━━━━
     ABOUT
━━━━━━━━━━━━━━━━━━

SmartQueue v1.0
Virtual Queue System

College MVP Project

Features:
• QR Code Check-in
• Real-time Updates
• Wait Time Estimates
• Mobile App Support

[9] Back
[0] Main Menu

━━━━━━━━━━━━━━━━━━
Enter option:''';
      _currentMenu = 'about';
    });
  }

  void _showNameInput() {
    setState(() {
      _isInputMode = true;
      _inputType = 'name';
      _displayText = '''
━━━━━━━━━━━━━━━━━━
   ENTER NAME
━━━━━━━━━━━━━━━━━━

Please enter your name:

$_nameInput

[#] Confirm
[*] Clear

━━━━━━━━━━━━━━━━━━''';
    });
  }

  void _showPhoneInput() {
    setState(() {
      _isInputMode = true;
      _inputType = 'phone';
      _displayText = '''
━━━━━━━━━━━━━━━━━━
  ENTER PHONE
━━━━━━━━━━━━━━━━━━

Please enter phone:

$_phoneInput

[#] Confirm & Join
[*] Clear

━━━━━━━━━━━━━━━━━━''';
    });
  }

  void _showSuccess() {
    setState(() {
      _displayText = '''
━━━━━━━━━━━━━━━━━━
    SUCCESS!
━━━━━━━━━━━━━━━━━━

✓ Joined Queue

${_queueData != null ? '''
Position: ${_queueData!['position']}
Wait Time: ${_queueData!['estimated_wait_time']} min
''' : ''}

You will receive SMS
updates on your turn.

[0] Main Menu

━━━━━━━━━━━━━━━━━━
Enter option:''';
      _currentMenu = 'success';
      _isInputMode = false;
    });
  }

  Future<void> _handleJoinQueue() async {
    try {
      // Use the default/first business ID
      final businesses = await _supabaseService.getAllBusinesses();
      if (businesses.isEmpty) {
        _showError('No businesses available');
        return;
      }

      final result = await _supabaseService.joinQueue(
        businessId: businesses[0]['id'],
        customerName: _nameInput,
        phoneNumber: _phoneInput,
      );

      setState(() {
        _queueData = result;
      });

      _showSuccess();
    } catch (e) {
      _showError('Failed to join queue');
    }
  }

  void _showError(String message) {
    setState(() {
      _displayText = '''
━━━━━━━━━━━━━━━━━━
     ERROR
━━━━━━━━━━━━━━━━━━

$message

Please try again.

[0] Main Menu

━━━━━━━━━━━━━━━━━━
Enter option:''';
      _currentMenu = 'error';
      _isInputMode = false;
    });
  }

  void _handleKeyPress(String key) {
    if (_isInputMode) {
      setState(() {
        if (key == '#') {
          // Confirm
          if (_inputType == 'name') {
            if (_nameInput.isNotEmpty) {
              _showPhoneInput();
            }
          } else if (_inputType == 'phone') {
            if (_phoneInput.isNotEmpty) {
              _handleJoinQueue();
            }
          }
        } else if (key == '*') {
          // Clear
          if (_inputType == 'name') {
            _nameInput = '';
            _showNameInput();
          } else if (_inputType == 'phone') {
            _phoneInput = '';
            _showPhoneInput();
          }
        } else {
          // Add character
          if (_inputType == 'name') {
            _nameInput += key;
            _showNameInput();
          } else if (_inputType == 'phone') {
            _phoneInput += key;
            _showPhoneInput();
          }
        }
      });
      return;
    }

    switch (_currentMenu) {
      case 'main':
        if (key == '1') {
          _showJoinMenu();
        } else if (key == '2') {
          _showCheckStatusMenu();
        } else if (key == '3') {
          _showAboutMenu();
        } else if (key == '0') {
          context.go('/');
        }
        break;

      case 'join':
        if (key == '1') {
          _nameInput = '';
          _phoneInput = '';
          _showNameInput();
        } else if (key == '9') {
          _showMainMenu();
        } else if (key == '0') {
          _showMainMenu();
        }
        break;

      case 'status':
      case 'about':
      case 'success':
      case 'error':
        if (key == '9') {
          _showMainMenu();
        } else if (key == '0') {
          _showMainMenu();
        }
        break;
    }
  }

  Widget _buildKeypadButton(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _handleKeyPress(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D2D2D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              if (label.isNotEmpty)
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('USSD Simulator'),
        backgroundColor: const Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          // Screen Display
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF90EE90),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2D2D2D), width: 4),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _displayText,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 14,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),

          // Keypad
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Row 1: 1, 2, 3
                  Expanded(
                    child: Row(
                      children: [
                        _buildKeypadButton('', '1'),
                        _buildKeypadButton('ABC', '2'),
                        _buildKeypadButton('DEF', '3'),
                      ],
                    ),
                  ),
                  // Row 2: 4, 5, 6
                  Expanded(
                    child: Row(
                      children: [
                        _buildKeypadButton('GHI', '4'),
                        _buildKeypadButton('JKL', '5'),
                        _buildKeypadButton('MNO', '6'),
                      ],
                    ),
                  ),
                  // Row 3: 7, 8, 9
                  Expanded(
                    child: Row(
                      children: [
                        _buildKeypadButton('PQRS', '7'),
                        _buildKeypadButton('TUV', '8'),
                        _buildKeypadButton('WXYZ', '9'),
                      ],
                    ),
                  ),
                  // Row 4: *, 0, #
                  Expanded(
                    child: Row(
                      children: [
                        _buildKeypadButton('', '*'),
                        _buildKeypadButton('+', '0'),
                        _buildKeypadButton('', '#'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Retro USSD Demo • SmartQueue',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
