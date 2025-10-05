import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  static final SpeechToText _speechToText = SpeechToText();
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _speechEnabled = false;
  static bool _isSpeaking = false; // <-- Add this

  static Future<void> initialize() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission not granted');
    }

    // Initialize speech to text
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('Speech to text error: $error'),
      onStatus: (status) => print('Speech to text status: $status'),
    );

    if (!_speechEnabled) {
      throw Exception('Speech to text not available');
    }

    // Initialize text to speech
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Add these handlers:
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });
    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
    });
  }

  // Start listening for speech
  static Future<void> startListening({
    required Function(String text) onResult,
    required Function() onError,
  }) async {
    if (!_speechEnabled) {
      onError();
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: false,
      localeId: "en_US",
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  // Stop listening
  static Future<void> stopListening() async {
    await _speechToText.stop();
  }

  // Speak text
  static Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Stop speaking
  static Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Parse voice input for transaction details
  static Map<String, dynamic> parseVoiceInput(String voiceText) {
    final text = voiceText.toLowerCase();
    final result = <String, dynamic>{};

    // Extract amount
    final amountRegex = RegExp(
        r'(\d+(?:\.\d{2})?)\s*(?:dollars?|dollars?|bucks?|euros?|pounds?)');
    final amountMatch = amountRegex.firstMatch(text);
    if (amountMatch != null) {
      result['amount'] = double.tryParse(amountMatch.group(1) ?? '');
    }

    // Extract category
    final categories = {
      'food': [
        'food',
        'restaurant',
        'dinner',
        'lunch',
        'breakfast',
        'groceries',
        'coffee'
      ],
      'transport': [
        'transport',
        'uber',
        'taxi',
        'gas',
        'fuel',
        'parking',
        'bus',
        'train'
      ],
      'shopping': [
        'shopping',
        'clothes',
        'shoes',
        'electronics',
        'amazon',
        'store'
      ],
      'entertainment': [
        'entertainment',
        'movie',
        'concert',
        'game',
        'netflix',
        'spotify'
      ],
      'health': ['health', 'medical', 'doctor', 'pharmacy', 'medicine'],
      'utilities': [
        'utilities',
        'electricity',
        'water',
        'internet',
        'phone',
        'wifi'
      ],
      'income': ['income', 'salary', 'payment', 'received', 'earned'],
    };

    for (final entry in categories.entries) {
      if (entry.value.any((keyword) => text.contains(keyword))) {
        result['category'] = entry.key;
        break;
      }
    }

    // Extract description
    final words = text.split(' ');
    final descriptionWords = <String>[];
    bool foundAmount = false;
    bool foundCategory = false;

    for (final word in words) {
      if (amountMatch != null && word.contains(amountMatch.group(1) ?? '')) {
        foundAmount = true;
        continue;
      }
      if (result['category'] != null &&
          categories[result['category']]!.contains(word)) {
        foundCategory = true;
        continue;
      }
      if (foundAmount || foundCategory) {
        descriptionWords.add(word);
      }
    }

    if (descriptionWords.isNotEmpty) {
      result['description'] = descriptionWords.join(' ');
    }

    // Determine transaction type
    if (result['category'] == 'income') {
      result['type'] = 'income';
    } else {
      result['type'] = 'expense';
    }

    return result;
  }

  // Voice-guided transaction entry
  static Future<Map<String, dynamic>> voiceGuidedTransactionEntry() async {
    final result = <String, dynamic>{};

    // Step 1: Ask for amount
    await speak("Please say the amount you spent or received");
    // TODO: Implement actual voice input here
    // For now, return a placeholder
    result['amount'] = 0.0;

    // Step 2: Ask for category
    await speak("What category is this transaction?");
    result['category'] = 'other';

    // Step 3: Ask for description
    await speak("Please describe this transaction");
    result['description'] = '';

    // Step 4: Ask for type
    await speak("Is this income or expense?");
    result['type'] = 'expense';

    return result;
  }

  // Voice commands for app navigation
  static List<String> getVoiceCommands() {
    return [
      'add transaction',
      'show balance',
      'show budget',
      'show goals',
      'show insights',
      'scan receipt',
      'voice entry',
      'ai chat',
    ];
  }

  // Process voice command
  static String processVoiceCommand(String command) {
    final text = command.toLowerCase();

    if (text.contains('add') && text.contains('transaction')) {
      return 'add_transaction';
    } else if (text.contains('balance')) {
      return 'show_balance';
    } else if (text.contains('budget')) {
      return 'show_budget';
    } else if (text.contains('goal')) {
      return 'show_goals';
    } else if (text.contains('insight')) {
      return 'show_insights';
    } else if (text.contains('receipt')) {
      return 'scan_receipt';
    } else if (text.contains('voice')) {
      return 'voice_entry';
    } else if (text.contains('chat') || text.contains('ai')) {
      return 'ai_chat';
    }

    return 'unknown';
  }

  // Check if speech is available
  static bool get isSpeechEnabled => _speechEnabled;
  // Check if currently listening
  static bool get isListening => _speechToText.isListening;
  // Check if currently speaking
  static bool get isSpeaking => _isSpeaking;
}
