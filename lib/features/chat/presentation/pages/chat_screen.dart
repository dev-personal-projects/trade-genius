/*
 * ═══════════════════════════════════════════════════════════════════════════
 * CHAT SCREEN - Complete AI Chat with Image Upload & History
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 📚 LEARNING GUIDE FOR ANDROID DEVELOPERS
 * 
 * This file demonstrates core Flutter concepts through a real-world chat application.
 * Each section is heavily documented to help you understand WHAT, WHY, WHEN, and HOW.
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 * TABLE OF CONTENTS:
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * 1. STATEFUL WIDGET PATTERN
 *    - What: Widgets that maintain mutable state
 *    - When: Use when UI needs to change based on user interaction or data
 *    - Why: Flutter rebuilds UI when state changes (declarative approach)
 * 
 * 2. LIFECYCLE METHODS
 *    - initState(): Called once when widget is created (like onCreate)
 *    - dispose(): Called when widget is removed (like onDestroy)
 *    - setState(): Triggers UI rebuild (like notifyDataSetChanged)
 * 
 * 3. CONTROLLERS
 *    - TextEditingController: Manages TextField input (like EditText)
 *    - ScrollController: Controls ListView scrolling (like RecyclerView)
 *    - Why: Separate data management from UI rendering
 * 
 * 4. ASYNC/AWAIT PATTERN
 *    - What: Handle asynchronous operations (network, database)
 *    - When: Any operation that takes time (API calls, file I/O)
 *    - Why: Prevents blocking UI thread (like Coroutines in Kotlin)
 * 
 * 5. STREAMS
 *    - What: Continuous flow of data over time
 *    - When: Real-time updates (WebSocket, AI token streaming)
 *    - Why: Reactive programming for live data (like Flow/LiveData)
 * 
 * 6. LISTVIEW.BUILDER
 *    - What: Efficiently renders scrollable lists
 *    - When: Displaying dynamic lists of data
 *    - Why: Only builds visible items (like RecyclerView)
 * 
 * 7. NAVIGATION
 *    - Navigator.push(): Navigate to new screen (like startActivity)
 *    - MaterialPageRoute: Defines screen transition
 *    - Why: Stack-based navigation (like Android back stack)
 * 
 * 8. IMAGE PICKER
 *    - What: Access device gallery/camera
 *    - When: User needs to upload images
 *    - Why: Platform-specific implementation abstracted
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/env_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/datasources/azure_ai_datasource.dart';
import '../../data/models/azure_request_model.dart';
import '../../data/datasources/chat_storage_datasource.dart';
import 'conversation_detail_screen.dart';

/*
 * ═══════════════════════════════════════════════════════════════════════════
 * STATEFUL WIDGET - The Container
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * WHAT: StatefulWidget is a widget that can change its appearance over time.
 * 
 * WHY: We need StatefulWidget (not StatelessWidget) because:
 *      - Chat messages change as user types and AI responds
 *      - Typing indicator appears/disappears
 *      - Scroll position changes
 *      - Image uploads modify UI
 * 
 * HOW IT WORKS:
 *      1. ChatScreen (StatefulWidget) is the immutable configuration
 *      2. _ChatScreenState holds the mutable state (messages, typing status)
 *      3. When state changes, Flutter rebuilds only affected widgets
 * 
 * TWO-CLASS PATTERN:
 *      - ChatScreen: Immutable widget configuration (never changes)
 *      - _ChatScreenState: Mutable state that changes over time
 * 
 * WHEN TO USE:
 *      - User interactions (button clicks, text input)
 *      - Animations
 *      - Real-time data updates
 *      - Form validation
 */
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

/*
 * ═══════════════════════════════════════════════════════════════════════════
 * STATE CLASS - The Brain
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * This class holds all the mutable state for the chat screen.
 * When any of these variables change, we call setState() to rebuild the UI.
 */
class _ChatScreenState extends State<ChatScreen> {
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROLLERS - Managing User Input and Scrolling
  // ═══════════════════════════════════════════════════════════════════════════
  
  // TextEditingController: Manages the text input field
  // WHAT: Controls the text in TextField, can read/write/clear text
  // WHY: Separates text data from UI, allows programmatic control
  // WHEN: Always use with TextField for better control
  // HOW: _textController.text to read, _textController.clear() to clear
  final TextEditingController _textController = TextEditingController();
  
  // ScrollController: Controls the ListView scroll position
  // WHAT: Programmatically scroll to any position in the list
  // WHY: Auto-scroll to bottom when new messages arrive
  // WHEN: Use when you need to control scrolling (not just user scrolling)
  // HOW: _scrollController.animateTo() or jumpTo()
  final ScrollController _scrollController = ScrollController();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // STATE VARIABLES - The Data That Changes
  // ═══════════════════════════════════════════════════════════════════════════
  
  // List of all chat messages (user + AI)
  // WHAT: Dynamic list that grows as conversation progresses
  // WHY: Need to display all messages in ListView
  // WHEN: Modified when user sends message or AI responds
  final List<ChatMessage> _messages = [];
  
  // Azure AI client for sending messages to GPT
  // WHAT: Handles HTTP requests to Azure AI Foundry API
  // WHY: Encapsulates API logic, makes code cleaner
  // WHEN: Initialized in initState(), used in _sendMessage()
  // NOTE: 'late' means "I'll initialize this before using it"
  late AzureAIDataSource _azureAI;
  
  // Supabase storage client for saving messages to database
  // WHAT: Handles database operations (save, load, delete)
  // WHY: Persist conversations so users can view history
  // WHEN: Initialized in initState(), used after each message
  late ChatStorageDataSource _storage;
  
  // Flag to show typing indicator when AI is responding
  // WHAT: Boolean that controls typing animation visibility
  // WHY: Provides visual feedback that AI is working
  // WHEN: Set to true when waiting for AI, false when done
  bool _isTyping = false;
  
  // Accumulates AI response tokens as they stream in
  // WHAT: String that builds up character by character
  // WHY: AI streams response token-by-token for better UX
  // WHEN: Reset to '' before streaming, grows during streaming
  // HOW: Each token from stream is appended: _streamingContent += token
  String _streamingContent = '';
  
  // Unique ID for current conversation session
  // WHAT: Timestamp-based ID to group messages
  // WHY: Allows multiple conversations, each with unique ID
  // WHEN: Generated in initState() using current timestamp
  String _currentSessionId = '';
  
  // Image picker for uploading photos
  // WHAT: Platform-specific image selection (gallery/camera)
  // WHY: Users can upload images for AI to describe
  // WHEN: Used when user taps image upload button
  final ImagePicker _imagePicker = ImagePicker();

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE METHOD: initState()
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Called ONCE when the State object is created (widget inserted into tree)
  // 
  // WHEN: Perfect for one-time initialization:
  //       - Initialize controllers
  //       - Set up API clients
  //       - Load initial data
  //       - Subscribe to streams
  //       - Add listeners
  // 
  // WHY: Separates initialization from build() which runs many times
  // 
  // IMPORTANT: Always call super.initState() first!
  // 
  // LIFECYCLE ORDER:
  // 1. Constructor (ChatScreen created)
  // 2. initState() ← YOU ARE HERE
  // 3. build() (UI rendered)
  // 4. User interacts, setState() called
  // 5. build() runs again (UI updated)
  // 6. dispose() (widget removed)
  //
  @override
  void initState() {
    super.initState(); // MUST call this first!
    
    // Initialize Azure AI client with credentials from .env file
    // WHY: Encapsulates API configuration in one place
    _azureAI = AzureAIDataSource(
      endpoint: EnvService.azureEndpoint,      // https://your-resource.openai.azure.com
      apiKey: EnvService.azureApiKey,          // Secret API key
      deploymentName: EnvService.azureDeployment, // gpt-4o-mini
      apiVersion: EnvService.azureApiVersion,  // 2025-01-01-preview
    );
    
    // Initialize Supabase storage client
    // WHY: Handles all database operations for message persistence
    _storage = ChatStorageDataSource();
    
    // Generate unique session ID using current timestamp
    // WHY: Groups messages into conversations, allows multiple chats
    // EXAMPLE: "1704067200000" (milliseconds since epoch)
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Add welcome message from AI
    // WHY: Greets user and explains capabilities
    // NOTE: false = not from user (from AI)
    _addMessage("Hi! I'm TradeGenius AI. Ask me about crypto or upload an image.", false);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE METHOD: dispose()
  // ═══════════════════════════════════════════════════════════════════════════
  // 
  // WHAT: Called when State object is removed permanently from widget tree
  // 
  // WHEN: Widget is destroyed (user navigates away, app closes)
  // 
  // WHY: Clean up resources to prevent memory leaks:
  //      - Dispose controllers (TextEditingController, ScrollController)
  //      - Cancel stream subscriptions
  //      - Close database connections
  //      - Remove listeners
  // 
  // CRITICAL: Always dispose controllers! They hold native resources.
  // 
  // IMPORTANT: Call super.dispose() LAST (opposite of initState)
  //
  @override
  void dispose() {
    // Dispose text controller to free memory
    // WHY: Controllers hold native platform resources
    _textController.dispose();
    
    // Dispose scroll controller
    _scrollController.dispose();
    
    // Call super.dispose() LAST
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHOD: _addMessage()
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHAT: Adds a new message to the chat (user or AI)
  //
  // PARAMETERS:
  //   - text: The message content
  //   - isUser: true if from user, false if from AI
  //   - imageUrl: Optional image path (for image uploads)
  //
  // WHAT IT DOES:
  //   1. Creates ChatMessage object with unique ID
  //   2. Adds to _messages list
  //   3. Calls setState() to rebuild UI
  //   4. Saves to Supabase database
  //   5. Scrolls to bottom to show new message
  //
  // WHY ASYNC: Database save takes time, don't block UI
  //
  void _addMessage(String text, bool isUser, {String? imageUrl}) async {
    // Create ChatMessage entity
    // WHAT: Domain model representing a single chat message
    // WHY: Type-safe data structure with all message properties
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
      sessionId: _currentSessionId,                         // Groups messages
      role: isUser ? MessageRole.user : MessageRole.assistant, // Who sent it
      content: text,                                        // Message text
      timestamp: DateTime.now(),                            // When sent
      metadata: imageUrl != null ? {'imageUrl': imageUrl} : null, // Extra data
    );
    
    // ═══════════════════════════════════════════════════════════════════════════
    // setState() - THE MOST IMPORTANT METHOD IN FLUTTER!
    // ═══════════════════════════════════════════════════════════════════════════
    //
    // WHAT: Tells Flutter "state changed, rebuild this widget"
    //
    // WHY: Flutter is DECLARATIVE (not imperative)
    //      - You don't manually update UI elements
    //      - You change state, Flutter rebuilds UI automatically
    //
    // HOW IT WORKS:
    //      1. You modify state inside setState(() { ... })
    //      2. Flutter marks widget as "dirty"
    //      3. Flutter calls build() method again
    //      4. New UI is rendered with updated data
    //
    // WHEN TO USE:
    //      - ANY time you change state variables
    //      - User interactions (button clicks, text input)
    //      - Data updates (API responses, database changes)
    //
    // CRITICAL: Only modify state INSIDE setState()!
    //           Bad:  _messages.add(message); setState(() {});
    //           Good: setState(() { _messages.add(message); });
    //
    setState(() {
      _messages.add(message); // Add to list, UI will rebuild
    });
    
    // Save to Supabase database (async operation)
    // WHY: Persist message so user can view history later
    // NOTE: await means "wait for this to complete before continuing"
    await _storage.saveMessage(message);
    
    // Auto-scroll to show the new message
    _scrollToBottom();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHOD: _scrollToBottom()
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHAT: Smoothly scrolls ListView to the bottom
  //
  // WHY: Show newest message when it arrives (better UX)
  //
  // HOW IT WORKS:
  //   1. addPostFrameCallback: Wait until UI finishes building
  //   2. hasClients: Check if ScrollController is attached to ListView
  //   3. animateTo: Smoothly scroll to maxScrollExtent (bottom)
  //
  // WHY addPostFrameCallback?
  //   - Can't scroll during build() (widget not rendered yet)
  //   - Wait for frame to complete, THEN scroll
  //   - Prevents "ScrollController not attached" errors
  //
  // PARAMETERS:
  //   - maxScrollExtent: Maximum scroll position (bottom of list)
  //   - duration: How long animation takes (300ms)
  //   - curve: Animation easing (Curves.easeOut = slow at end)
  //
  void _scrollToBottom() {
    // Schedule callback to run AFTER current frame finishes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if ScrollController is attached to a scrollable widget
      // WHY: Prevents crash if ListView not built yet
      if (_scrollController.hasClients) {
        // Animate scroll to bottom
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, // Bottom position
          duration: const Duration(milliseconds: 300), // Animation speed
          curve: Curves.easeOut,                       // Smooth deceleration
        );
      }
    });
  }

  // Handle image upload
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image == null) return;
      
      _addMessage("Uploaded an image", true, imageUrl: image.path);
      
      setState(() {
        _isTyping = true;
        _streamingContent = '';
      });
      
      final messages = <AzureMessage>[
        const AzureMessage(
          role: 'system',
          content: 'You are an AI that describes images in detail.',
        ),
        const AzureMessage(
          role: 'user',
          content: 'Describe this image: [Image uploaded]',
        ),
      ];
      
      final request = AzureRequest(messages: messages, stream: true);
      await for (final token in _azureAI.streamMessage(request)) {
        setState(() => _streamingContent += token);
      }
      
      if (_streamingContent.isNotEmpty) {
        _addMessage(_streamingContent, false);
      }
    } catch (e) {
      _addMessage("Error: ${e.toString()}", false);
    } finally {
      setState(() {
        _isTyping = false;
        _streamingContent = '';
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CORE METHOD: _sendMessage()
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHAT: Sends user's message to AI and streams the response
  //
  // FLOW:
  //   1. Validate input (not empty, not already typing)
  //   2. Add user message to chat
  //   3. Show typing indicator
  //   4. Build conversation context (last 6 messages)
  //   5. Stream AI response token-by-token
  //   6. Display each token as it arrives
  //   7. Save complete AI response
  //   8. Hide typing indicator
  //
  // WHY ASYNC: Network requests take time, don't block UI
  //
  // WHY STREAM: Better UX - user sees response building in real-time
  //             (like ChatGPT, not waiting for full response)
  //
  void _sendMessage() async {
    // Get text from TextField and remove whitespace
    final text = _textController.text.trim();
    
    // Validation: Don't send if empty or AI is already responding
    if (text.isEmpty || _isTyping) return;

    // Add user's message to chat immediately
    _addMessage(text, true);
    
    // Clear input field for next message
    _textController.clear();

    // Update UI: Show typing indicator, reset streaming content
    setState(() {
      _isTyping = true;           // Show "..." animation
      _streamingContent = '';     // Clear previous stream
    });

    // ═══════════════════════════════════════════════════════════════════════════
    // TRY-CATCH-FINALLY: Error Handling Pattern
    // ═══════════════════════════════════════════════════════════════════════════
    // try: Attempt risky operation (network request)
    // catch: Handle errors gracefully (show error message)
    // finally: Always runs (cleanup, hide loading indicator)
    //
    try {
      // Build conversation context for AI
      // WHY: AI needs recent messages to understand context
      final messages = <AzureMessage>[
        // System prompt: Defines AI personality and behavior
        const AzureMessage(
          role: 'system',
          content: 'You are TradeGenius AI, a crypto trading mentor. Be concise and helpful.',
        ),
        // Add last 6 messages for context (reversed to chronological order)
        // WHY: Limit context to save tokens and improve response time
        ..._messages.take(6).toList().reversed.map((msg) => AzureMessage(
              role: msg.isUser ? 'user' : 'assistant',
              content: msg.content,
            )),
        // Add current user message
        AzureMessage(role: 'user', content: text),
      ];

      // Create API request with streaming enabled
      final request = AzureRequest(messages: messages, stream: true);
      
      // ═══════════════════════════════════════════════════════════════════════════
      // STREAM: Continuous flow of data
      // ═══════════════════════════════════════════════════════════════════════════
      // WHAT: Stream<String> emits tokens one at a time
      // WHY: Show response as it's generated (better UX)
      // HOW: await for loop processes each token as it arrives
      //
      // EXAMPLE:
      //   Token 1: "Hello"
      //   Token 2: " there"
      //   Token 3: "!"
      //   Result: "Hello there!"
      //
      await for (final token in _azureAI.streamMessage(request)) {
        // Append token to streaming content and rebuild UI
        setState(() => _streamingContent += token);
        // Keep scrolling to show new tokens
        _scrollToBottom();
      }

      // Stream complete, save full AI response
      if (_streamingContent.isNotEmpty) {
        _addMessage(_streamingContent, false);
      }
    } catch (e) {
      // Error occurred (network failure, API error, etc.)
      // Show error message to user
      _addMessage("Error: ${e.toString()}", false);
    } finally {
      // ALWAYS runs (success or error)
      // Clean up: Hide typing indicator, clear streaming content
      setState(() {
        _isTyping = false;
        _streamingContent = '';
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION: _showHistory()
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHAT: Navigate to conversation history screen
  //
  // HOW NAVIGATION WORKS:
  //   1. Navigator maintains a stack of screens (like Android back stack)
  //   2. push() adds new screen on top
  //   3. pop() removes current screen (back button)
  //
  // NAVIGATOR METHODS:
  //   - Navigator.push(): Go to new screen
  //   - Navigator.pop(): Go back
  //   - Navigator.pushReplacement(): Replace current screen
  //   - Navigator.pushNamed(): Navigate using route name
  //
  // MaterialPageRoute:
  //   - Defines screen transition animation
  //   - Platform-specific (slide on iOS, fade on Android)
  //   - builder: Function that returns the new screen widget
  //
  void _showHistory() {
    Navigator.push(
      context,                    // Current context
      MaterialPageRoute(          // Route with Material transition
        builder: (context) => const ConversationHistoryScreen(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE METHOD: build()
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // WHAT: Describes the UI structure (widget tree)
  //
  // WHEN: Called MANY times:
  //       - After initState()
  //       - After setState()
  //       - When parent widget rebuilds
  //       - When device rotates
  //       - When theme changes
  //
  // WHY: Flutter is DECLARATIVE
  //      - You describe WHAT UI should look like
  //      - Flutter figures out HOW to render it
  //      - No findViewById, no manual UI updates
  //
  // IMPORTANT: build() should be FAST and PURE
  //            - No side effects (no API calls, no setState)
  //            - Only build widgets based on current state
  //            - Can run 60+ times per second during animations
  //
  // WIDGET TREE:
  //   Scaffold (Material Design structure)
  //   ├── AppBar (top bar with title and actions)
  //   └── Column (vertical layout)
  //       ├── Expanded + ListView.builder (scrollable messages)
  //       └── _buildInputBar (text input at bottom)
  //
  @override
  Widget build(BuildContext context) {
    // Get current theme (colors, text styles, etc.)
    // WHY: Respects user's dark/light mode preference
    final theme = Theme.of(context);

    // ═══════════════════════════════════════════════════════════════════════════
    // SCAFFOLD: Material Design screen structure
    // ═══════════════════════════════════════════════════════════════════════════
    // WHAT: Provides basic screen structure (AppBar, body, FAB, drawer, etc.)
    // WHY: Handles Material Design layout automatically
    // WHEN: Use for almost every screen in your app
    //
    return Scaffold(
      // ═══════════════════════════════════════════════════════════════════════════
      // APPBAR: Top navigation bar
      // ═══════════════════════════════════════════════════════════════════════════
      appBar: AppBar(
        title: const Text('TradeGenius AI'), // Screen title
        actions: [
          // Action buttons on the right side of AppBar
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory, // Navigate to history screen
            tooltip: 'Conversation History', // Shows on long press
          ),
        ],
      ),
      // ═══════════════════════════════════════════════════════════════════════════
      // BODY: Main content area
      // ═══════════════════════════════════════════════════════════════════════════
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════════════════
          // EXPANDED: Takes all available space
          // ═══════════════════════════════════════════════════════════════════════════
          // WHY: Messages take remaining space, input bar stays at bottom
          Expanded(
            // ═══════════════════════════════════════════════════════════════════════════
            // LISTVIEW.BUILDER: Efficient scrollable list
            // ═══════════════════════════════════════════════════════════════════════════
            // WHAT: Lazily builds list items (only visible ones)
            // WHY: Performance - doesn't build 1000 items if only 10 visible
            // WHEN: Use for any scrollable list of data
            //
            child: ListView.builder(
              controller: _scrollController, // For programmatic scrolling
              padding: const EdgeInsets.all(16),
              // Item count: messages + 1 if typing (for typing indicator)
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              // itemBuilder: Called for each visible item
              // PARAMETERS:
              //   - context: BuildContext for this item
              //   - index: Position in list (0, 1, 2, ...)
              // RETURNS: Widget to display at this index
              itemBuilder: (context, index) {
                // Show typing indicator as last item when AI is responding
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator(theme);
                }
                
                // Get message at this index and build bubble
                final message = _messages[index];
                return _buildMessageBubble(message, theme);
              },
            ),
          ),
          // Input bar at bottom (not scrollable)
          _buildInputBar(theme),
        ],
      ),
    );
  }

  // Build typing indicator (animated dots)
  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated typing dots
            _TypingDot(delay: 0),
            const SizedBox(width: 4),
            _TypingDot(delay: 200),
            const SizedBox(width: 4),
            _TypingDot(delay: 400),
          ],
        ),
      ),
    );
  }

  // Build message bubble
  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    final hasImage = message.metadata?['imageUrl'] != null;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show image if present
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(message.metadata!['imageUrl']!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            if (hasImage) const SizedBox(height: 8),
            // Show text
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build input bar with image upload button
  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Image upload button
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _isTyping ? null : _pickImage,
              tooltip: 'Upload Image',
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !_isTyping,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: 4,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isTyping ? null : _sendMessage,
              icon: Icon(
                Icons.send,
                color: _isTyping ? Colors.grey : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated typing dot widget
class _TypingDot extends StatefulWidget {
  final int delay;
  
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Delay animation start
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3 + (_animation.value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// Conversation History Screen
/*
 * ═══════════════════════════════════════════════════════════════════════════
 * CONVERSATION HISTORY SCREEN
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * FEATURES:
 * - Pull-to-refresh: Reload conversation list
 * - Swipe-to-delete: Swipe left to delete conversation
 * - Tap to view: Open conversation details
 * 
 * NEW CONCEPTS:
 * - RefreshIndicator: Pull-down to refresh gesture
 * - Dismissible: Swipe-to-dismiss gesture
 * - Key: Unique identifier for widgets
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */
class ConversationHistoryScreen extends StatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  State<ConversationHistoryScreen> createState() =>
      _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends State<ConversationHistoryScreen> {
  late ChatStorageDataSource _storage;
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storage = ChatStorageDataSource();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await _storage.getAllSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(child: Text('No conversations yet'))
              // ═══════════════════════════════════════════════════════════════════
              // REFRESHINDICATOR: Pull-to-refresh
              // ═══════════════════════════════════════════════════════════════════
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    // ═══════════════════════════════════════════════════════════════════
                    // DISMISSIBLE: Swipe-to-delete widget
                    // ═══════════════════════════════════════════════════════════════════
                    // WHAT: Allows widget to be dismissed by swiping
                    // WHY: Standard mobile UX for delete actions
                    // HOW: Wrap item, provide key and callbacks
                    //
                    // USER INTERACTION:
                    // 1. User swipes item left or right
                    // 2. Background widget appears (red with delete icon)
                    // 3. If swiped far enough, onDismissed() called
                    // 4. Item animates out and is removed
                    //
                    // KEY CONCEPTS:
                    // - key: Unique identifier (required for Dismissible)
                    // - direction: Which directions allow dismissal
                    // - background: Widget shown behind during swipe
                    // - onDismissed: Called when item fully dismissed
                    // - confirmDismiss: Optional confirmation before dismiss
                    //
                    return Dismissible(
                      // ═══════════════════════════════════════════════════════════════════
                      // KEY: Unique identifier for this widget
                      // ═══════════════════════════════════════════════════════════════════
                      // WHAT: Identifies widget in widget tree
                      // WHY: Flutter needs to track which item was dismissed
                      // WHEN: Required for Dismissible, ListView with changing data
                      //
                      // KEY TYPES:
                      // - ValueKey: Based on value (id, string, number)
                      // - ObjectKey: Based on object reference
                      // - UniqueKey: Always unique (generates new each time)
                      // - GlobalKey: Access widget from anywhere
                      //
                      // BEST PRACTICE: Use stable, unique value (like database ID)
                      //
                      key: ValueKey(session['session_id']),
                      
                      // direction: Which swipe directions trigger dismiss
                      // - DismissDirection.endToStart: Swipe left (right to left)
                      // - DismissDirection.startToEnd: Swipe right (left to right)
                      // - DismissDirection.horizontal: Both directions
                      // - DismissDirection.vertical: Up or down
                      direction: DismissDirection.endToStart,
                      
                      // ═══════════════════════════════════════════════════════════════════
                      // background: Widget shown behind item during swipe
                      // ═══════════════════════════════════════════════════════════════════
                      // Typically shows delete icon and red background
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      
                      // ═══════════════════════════════════════════════════════════════════
                      // onDismissed: Called when item is fully dismissed
                      // ═══════════════════════════════════════════════════════════════════
                      // PARAMETER: direction (which way user swiped)
                      // WHEN: After swipe animation completes
                      // USE FOR: Delete from database, update state
                      onDismissed: (direction) async {
                        // Delete from database
                        await _storage.deleteSession(session['session_id']);
                        
                        // Remove from local list (UI updates automatically)
                        setState(() {
                          _sessions.removeAt(index);
                        });
                        
                        // Show confirmation message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conversation deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      
                      // child: The actual list item
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(session['first_message'] ?? 'Conversation'),
                          subtitle: Text('${session['message_count']} messages'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConversationDetailScreen(
                                  sessionId: session['session_id'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
