import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GateNotifier extends StateNotifier<String?> {
  GateNotifier() : super(null) {
    _loadGate();
  }

  static const String _gateKey = 'selected_gate_name';

  Future<void> _loadGate() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_gateKey);
  }

  Future<void> setGate(String? gateName) async {
    final prefs = await SharedPreferences.getInstance();
    if (gateName == null) {
      await prefs.remove(_gateKey);
    } else {
      await prefs.setString(_gateKey, gateName);
    }
    state = gateName;
  }
}

final gateProvider = StateNotifierProvider<GateNotifier, String?>((ref) {
  return GateNotifier();
});

const List<String> kAvailableGates = [
  'Gate A',
  'Gate B',
  'VIP Gate',
  'Family Gate',
];
