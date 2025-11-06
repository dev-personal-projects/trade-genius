/*
 * ═══════════════════════════════════════════════════════════════════════════
 * CONVERSATION DETAIL SCREEN - Deep Dive into Flutter Concepts
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * PURPOSE: Display all messages from a specific conversation session
 * 
 * FLUTTER CONCEPTS COVERED:
 * 1. StatefulWidget vs StatelessWidget
 * 2. FutureBuilder - Handling async data loading
 * 3. ListView.builder - Efficient list rendering
 * 4. Navigator - Screen navigation and passing data
 * 5. Theme - Accessing app-wide styling
 * 6. Conditional rendering - Show different UI based on state
 * 7. Widget composition - Building complex UI from simple widgets
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/datasources/chat_storage_datasource.dart';

/*
 * ═══════════════════════════════════════════════════════════════════════════
 * STATEFUL WIDGET EXPLAINED
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * StatefulWidget: A widget that can change over time
 * 
 * WHY USE IT?
 * - When UI needs to update based on user interaction
 * - When loading data from database/API
 * - When managing form inputs
 * - When handling animations
 * 
 * LIFECYCLE:
 * 1. Constructor called (ConversationDetailScreen created)
 * 2. createState() called (creates _ConversationDetailScreenState)
 * 3. initState() called (setup code runs once)
 * 4. build() called (UI is rendered)
 * 5. setState() called when data changes (triggers rebuild)
 * 6. build() called again (UI updates with new data)
 * 7. dispose() called when widget is removed (cleanup)
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */
class ConversationDetailScreen extends StatefulWidget {
  // final: Variable that cannot be changed after initialization
  // This is the session ID passed from the previous screen
  final String sessionId;

  // Constructor: Creates instance of this widget
  // {required this.sessionId}: Named parameter that must be provided
  // super.key: Passes key to parent StatefulWidget class
  const ConversationDetailScreen({
    super.key,
    required this.sessionId,
  });

  // createState(): Creates the mutable state for this widget
  // Called by Flutter framework, not by you
  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

/*
 * ═══════════════════════════════════════════════════════════════════════════
 * STATE CLASS EXPLAINED
 * ═══════════════════════════════════════════════════════════════════════════
 * 
 * State<T>: Holds mutable data and logic for a StatefulWidget
 * 
 * KEY POINTS:
 * - Contains all variables that can change
 * - Has access to widget properties via widget.propertyName
 * - Can call setState() to trigger UI rebuild
 * - Lives longer than build() method (persists across rebuilds)
 * 
 * ═══════════════════════════════════════════════════════════════════════════
 */
class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  // late: Variable will be initialized before first use (not immediately)
  // Used when initialization requires context or async operations
  late ChatStorageDataSource _storage;

  // List: Ordered collection of items (like Array in other languages)
  // ChatMessage: Custom data type defined in domain layer
  List<ChatMessage> _messages = [];

  // bool: Boolean value (true or false)
  // Used to track loading state and show/hide loading indicator
  bool _isLoading = true;

  /*
   * ═══════════════════════════════════════════════════════════════════════
   * LIFECYCLE METHOD: initState()
   * ═══════════════════════════════════════════════════════════════════════
   * 
   * WHEN: Called ONCE when State object is first created
   * 
   * USE FOR:
   * - Initialize variables
   * - Start timers
   * - Subscribe to streams
   * - Load initial data
   * - Setup controllers
   * 
   * RULES:
   * - Must call super.initState() first
   * - Cannot use setState() here (widget not built yet)
   * - Cannot access inherited widgets here
   * - Keep it fast (no heavy computation)
   * 
   * ═══════════════════════════════════════════════════════════════════════
   */
  @override
  void initState() {
    super.initState(); // Always call super first
    
    // Initialize storage client
    _storage = ChatStorageDataSource();
    
    // Load messages from database
    // This is async, so it runs in background
    _loadMessages();
  }

  /*
   * ═══════════════════════════════════════════════════════════════════════
   * ASYNC FUNCTION EXPLAINED
   * ═══════════════════════════════════════════════════════════════════════
   * 
   * async: Marks function as asynchronous
   * - Can use 'await' keyword inside
   * - Returns Future<T> automatically
   * - Doesn't block UI thread
   * 
   * await: Waits for Future to complete
   * - Pauses function execution
   * - Doesn't freeze UI
   * - Returns the actual value (not Future)
   * 
   * Future: Represents a value that will be available later
   * - Like Promise in JavaScript
   * - Used for database queries, API calls, file I/O
   * 
   * EXAMPLE FLOW:
   * 1. _loadMessages() called
   * 2. await _storage.getSessionMessages() starts
   * 3. Function pauses, UI remains responsive
   * 4. Database query completes
   * 5. Function resumes with messages
   * 6. setState() called
   * 7. UI rebuilds with new data
   * 
   * ═══════════════════════════════════════════════════════════════════════
   */
  Future<void> _loadMessages() async {
    // await: Wait for database query to complete
    // Returns List<ChatMessage> when done
    final messages = await _storage.getSessionMessages(widget.sessionId);
    
    // setState(): Tell Flutter "data changed, rebuild UI"
    // Everything inside this function modifies state variables
    // After setState() completes, build() is called automatically
    setState(() {
      _messages = messages; // Update messages list
      _isLoading = false;   // Hide loading indicator
    });
  }

  /*
   * ═══════════════════════════════════════════════════════════════════════
   * BUILD METHOD EXPLAINED
   * ═══════════════════════════════════════════════════════════════════════
   * 
   * build(): Returns the widget tree (UI structure)
   * 
   * WHEN CALLED:
   * - After initState() (first time)
   * - After setState() (every time)
   * - When parent widget rebuilds
   * - When dependencies change (Theme, MediaQuery, etc.)
   * 
   * RULES:
   * - Must return a Widget
   * - Should be fast (no heavy computation)
   * - Should be pure (same input = same output)
   * - Don't modify state here (no setState)
   * 
   * PERFORMANCE:
   * - Flutter is smart: only rebuilds changed widgets
   * - Use const constructors when possible
   * - Extract complex widgets to separate methods/classes
   * 
   * ═══════════════════════════════════════════════════════════════════════
   */
  @override
  Widget build(BuildContext context) {
    /*
     * BuildContext: Handle to location in widget tree
     * - Required for navigation, theme access, media queries
     * - Passed automatically by Flutter
     * - Each widget has its own context
     */
    
    /*
     * Theme.of(context): Access app-wide theme
     * - Returns ThemeData object
     * - Contains colors, text styles, etc.
     * - Defined in main.dart
     * - Changes automatically with dark/light mode
     */
    final theme = Theme.of(context);

    /*
     * ═══════════════════════════════════════════════════════════════════
     * SCAFFOLD WIDGET
     * ═══════════════════════════════════════════════════════════════════
     * 
     * Scaffold: Basic app structure
     * - Provides appBar, body, bottomNavigationBar, drawer, etc.
     * - Handles safe areas automatically
     * - Manages floating action buttons
     * - Shows snackbars and bottom sheets
     * 
     * PROPERTIES:
     * - appBar: Top bar with title and actions
     * - body: Main content area
     * - floatingActionButton: Circular button (usually bottom-right)
     * - drawer: Side menu (swipe from left)
     * - bottomNavigationBar: Bottom tabs
     * 
     * ═══════════════════════════════════════════════════════════════════
     */
    return Scaffold(
      /*
       * AppBar: Top navigation bar
       * - Shows title, back button, action buttons
       * - Automatically adds back button when pushed via Navigator
       * - Can customize colors, elevation, height
       */
      appBar: AppBar(
        title: const Text('Conversation'),
        // actions: List of widgets shown on the right side
        actions: [
          // IconButton: Clickable icon
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteConversation(context),
            tooltip: 'Delete Conversation',
          ),
        ],
      ),
      
      /*
       * ═══════════════════════════════════════════════════════════════════
       * CONDITIONAL RENDERING
       * ═══════════════════════════════════════════════════════════════════
       * 
       * Ternary operator: condition ? ifTrue : ifFalse
       * - Compact way to choose between two widgets
       * - Evaluated during build()
       * - Common pattern in Flutter
       * 
       * PATTERN:
       * _isLoading ? LoadingWidget : ContentWidget
       * 
       * ALTERNATIVES:
       * - if/else statements
       * - Switch expressions
       * - Builder widgets
       * 
       * ═══════════════════════════════════════════════════════════════════
       */
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? const Center(child: Text('No messages in this conversation'))
              // ═══════════════════════════════════════════════════════════════════
              // REFRESHINDICATOR: Pull-to-refresh functionality
              // ═══════════════════════════════════════════════════════════════════
              // WHAT: Adds pull-down gesture to refresh content
              // WHY: Standard mobile UX pattern for refreshing data
              // HOW: Wrap scrollable widget, provide onRefresh callback
              //
              // USER INTERACTION:
              // 1. User pulls down from top of list
              // 2. Loading indicator appears
              // 3. onRefresh() called (returns Future)
              // 4. Indicator shows until Future completes
              // 5. List updates with new data
              //
              // REQUIREMENTS:
              // - Child must be scrollable (ListView, GridView, etc.)
              // - onRefresh must return Future<void>
              // - Future completes when data is loaded
              //
              : RefreshIndicator(
                  // onRefresh: Called when user pulls down
                  // Must return Future that completes when refresh is done
                  onRefresh: _loadMessages,
                  child: ListView.builder(
                  /*
                   * ═══════════════════════════════════════════════════════
                   * LISTVIEW.BUILDER EXPLAINED
                   * ═══════════════════════════════════════════════════════
                   * 
                   * ListView.builder: Efficient scrollable list
                   * 
                   * WHY USE IT?
                   * - Only builds visible items (lazy loading)
                   * - Recycles off-screen items (memory efficient)
                   * - Handles thousands of items smoothly
                   * - Automatically scrollable
                   * 
                   * HOW IT WORKS:
                   * 1. Flutter calculates visible area
                   * 2. Calls itemBuilder for visible indices
                   * 3. Renders returned widgets
                   * 4. User scrolls
                   * 5. New items become visible
                   * 6. itemBuilder called for new indices
                   * 7. Old items recycled
                   * 
                   * ALTERNATIVES:
                   * - ListView: For small, fixed lists
                   * - GridView.builder: For grid layouts
                   * - CustomScrollView: For complex scrolling
                   * 
                   * ═══════════════════════════════════════════════════════
                   */
                  
                  // padding: Space around list content
                  // EdgeInsets.all(16): 16 pixels on all sides
                  padding: const EdgeInsets.all(16),
                  
                  // itemCount: Total number of items in list
                  // Required by builder to know when to stop
                  itemCount: _messages.length,
                  
                  /*
                   * itemBuilder: Function called for each item
                   * 
                   * PARAMETERS:
                   * - context: BuildContext for this item
                   * - index: Position in list (0, 1, 2, ...)
                   * 
                   * RETURNS:
                   * - Widget to display at this position
                   * 
                   * CALLED:
                   * - Only for visible items
                   * - When scrolling brings new items into view
                   * - After setState() if data changed
                   */
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageBubble(message, theme);
                  },
                ),
              ),
    );
  }

  /*
   * ═══════════════════════════════════════════════════════════════════════
   * WIDGET COMPOSITION
   * ═══════════════════════════════════════════════════════════════════════
   * 
   * Breaking UI into smaller methods/widgets
   * 
   * BENEFITS:
   * - Easier to read and maintain
   * - Reusable components
   * - Better performance (can optimize separately)
   * - Easier testing
   * 
   * WHEN TO EXTRACT:
   * - Widget used multiple times
   * - Complex widget (>50 lines)
   * - Independent functionality
   * - Performance optimization needed
   * 
   * ═══════════════════════════════════════════════════════════════════════
   */
  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    
    /*
     * ═══════════════════════════════════════════════════════════════════
     * ALIGN WIDGET
     * ═══════════════════════════════════════════════════════════════════
     * 
     * Align: Positions child within parent
     * 
     * ALIGNMENTS:
     * - Alignment.centerLeft: Left side, vertically centered
     * - Alignment.centerRight: Right side, vertically centered
     * - Alignment.topCenter: Top, horizontally centered
     * - Alignment.bottomLeft: Bottom-left corner
     * - Alignment(x, y): Custom (-1 to 1 for each axis)
     * 
     * USE CASES:
     * - Chat bubbles (left for received, right for sent)
     * - Floating buttons
     * - Badges on icons
     * 
     * ═══════════════════════════════════════════════════════════════════
     */
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      
      /*
       * ═══════════════════════════════════════════════════════════════════
       * CONTAINER WIDGET
       * ═══════════════════════════════════════════════════════════════════
       * 
       * Container: Box with styling
       * 
       * PROPERTIES:
       * - margin: Space outside container
       * - padding: Space inside container
       * - decoration: Background, border, shadow, etc.
       * - constraints: Min/max width/height
       * - transform: Rotation, scale, translation
       * - child: Widget inside container
       * 
       * THINK OF IT AS:
       * - HTML div with CSS
       * - Android FrameLayout with background
       * 
       * ═══════════════════════════════════════════════════════════════════
       */
      child: Container(
        // margin: Space outside (between bubbles)
        margin: const EdgeInsets.only(bottom: 12),
        
        // padding: Space inside (around text)
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        
        /*
         * BoxConstraints: Size limits
         * - maxWidth: Maximum width (75% of screen)
         * - minWidth: Minimum width
         * - maxHeight: Maximum height
         * - minHeight: Minimum height
         * 
         * MediaQuery.of(context): Get device info
         * - size.width: Screen width in pixels
         * - size.height: Screen height
         * - orientation: Portrait or landscape
         * - padding: Safe area insets
         */
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        
        /*
         * BoxDecoration: Visual styling
         * 
         * PROPERTIES:
         * - color: Background color
         * - gradient: Linear/radial gradient
         * - border: Border around container
         * - borderRadius: Rounded corners
         * - boxShadow: Drop shadow
         * - shape: Rectangle or circle
         * - image: Background image
         */
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        
        // child: Single widget inside container
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : theme.colorScheme.onSurface,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  /*
   * ═══════════════════════════════════════════════════════════════════════
   * ASYNC OPERATIONS WITH USER FEEDBACK
   * ═══════════════════════════════════════════════════════════════════════
   * 
   * Pattern: Show dialog → Perform action → Close dialog → Navigate back
   * 
   * ═══════════════════════════════════════════════════════════════════════
   */
  Future<void> _deleteConversation(BuildContext context) async {
    /*
     * showDialog: Display modal dialog
     * - Blocks interaction with background
     * - Returns Future<T?> (value from Navigator.pop)
     * - Can be dismissed by tapping outside (barrierDismissible)
     */
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If user confirmed deletion
    if (confirmed == true) {
      // Delete from database
      await _storage.deleteSession(widget.sessionId);
      
      /*
       * Navigator.pop: Go back to previous screen
       * - Removes current route from stack
       * - Can pass data back to previous screen
       * - Triggers dispose() on current widget
       */
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
