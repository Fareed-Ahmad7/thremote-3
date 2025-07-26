import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remote/models/device_model.dart';
import 'package:remote/utils/channel_pill.dart';
import 'package:remote/utils/pie_dpad_widget.dart';
import 'package:remote/utils/stb_service.dart';
import 'package:remote/utils/volume_pill.dart';

class RemoteControlScreen extends StatefulWidget {
  final DeviceModel deviceModel;

  const RemoteControlScreen({super.key, required this.deviceModel});

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> {
  final remote = STBRemoteService();

  Future<void> sendSTBKey(int code) async {
    HapticFeedback.mediumImpact();
    await remote.sendKey(
      widget.deviceModel.ipAddress,
      widget.deviceModel.pairingCode!,
      code,
    );
  }

  Future<void> sendSTBText(String text) async {
    HapticFeedback.mediumImpact();
    await remote.sendText(
      widget.deviceModel.ipAddress,
      widget.deviceModel.pairingCode!,
      text,
    );
  }

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isKeyboardVisible = false;

  Future<void> _sendCharacter(String value) async {
    if (value.isNotEmpty) {
      final char = value.substring(value.length - 1);
      debugPrint('Send to STB: $char');
      await sendSTBText(char);
    }
  }

  Widget _buildButton(int number) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: () async {
          await sendSTBKey(128 + number);
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black54,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void clearKeyboardFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void showFunctionButtonsSheet(BuildContext context) {
    clearKeyboardFocus(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(243, 243, 243, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _functionButton('F1', Colors.red, 178),
                    _functionButton('F2', Colors.green, 177),
                    _functionButton('F3', Colors.yellow[700]!, 185),
                    _functionButton('F4', Colors.blue, 186),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      FocusScope.of(context).unfocus();
    });
  }

  Widget _functionButton(String label, Color textColor, int rcCode) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          onPressed: () async => await sendSTBKey(rcCode),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget abcButton() {
    return ElevatedButton(
      onPressed: () {
        if (_isKeyboardVisible) {
          _focusNode.unfocus();
        } else {
          FocusScope.of(context).requestFocus(_focusNode);
        }
        _isKeyboardVisible = !_isKeyboardVisible;
      },
      // onPressed: () {
      //   _focusNode.unfocus(); // Force unfocus first
      //   Future.delayed(Duration.zero, () {
      //     // Ensure UI cycle completes
      //     FocusScope.of(context).requestFocus(_focusNode);
      //   });
      // },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(60, 60),
      ),
      child: const Text(
        "ABC",
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget fourDotsButton() {
    return ElevatedButton(
      onPressed: () {
        showFunctionButtonsSheet(context);
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(60, 60),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(Colors.orange),
              const SizedBox(width: 1),
              _buildDot(Colors.red),
            ],
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(Colors.green),
              const SizedBox(width: 1),
              _buildDot(Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: EdgeInsets.all(1),
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _iconCircleButton(IconData icon, int rcCode) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () async => await sendSTBKey(rcCode),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }

  Widget _homeButton(IconData icon, int rcCode) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: () async => await sendSTBKey(rcCode),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }

  @override
  void dispose() {
    remote.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(243, 243, 243, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 24),
              // Hidden TextField
              Opacity(
                opacity: 0.0,
                child: SizedBox(
                  height: 2,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: false,
                    onChanged: (value) async {
                      await _sendCharacter(value);
                      _controller.clear();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Text(
                          widget.deviceModel.deviceName,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      Positioned(
                        left: 0,
                        child: InkWell(
                          onTap: () async {
                            await sendSTBKey(140);
                          },

                          child: Icon(
                            size: 28,
                            Icons.power_settings_new,
                            color: Color.fromRGBO(192, 24, 81, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(1),
                      _buildButton(2),
                      _buildButton(3),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(4),
                      _buildButton(5),
                      _buildButton(6),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildButton(7),
                      _buildButton(8),
                      _buildButton(9),
                    ],
                  ),
                  SizedBox(
                    width: 250,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          // top: 20,
                          child: _buildButton(0),
                        ),
                        Positioned(left: 0, top: 20, child: fourDotsButton()),
                        Positioned(right: 0, top: 20, child: abcButton()),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    VolumeControlPill(
                      onClick: (code) async {
                        await sendSTBKey(code);
                      },
                    ),
                    PieDPad(
                      onClick: (code) async {
                        await sendSTBKey(code);
                      },
                    ),
                    ChannelControlPill(
                      onClick: (code) async {
                        await sendSTBKey(code);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Home, Back, Info, Mute
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _iconCircleButton(Icons.volume_off, 176),
                      _iconCircleButton(Icons.arrow_back, 143),
                      _homeButton(Icons.home, 141),
                      _iconCircleButton(Icons.info_outline, 157),
                      _iconCircleButton(Icons.menu_rounded, 138),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Rewind, Play/Pause, Fast Forward
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconCircleButton(Icons.fast_rewind, 150),
                      _iconCircleButton(CupertinoIcons.playpause_fill, 139),
                      _iconCircleButton(Icons.fast_forward, 144),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
