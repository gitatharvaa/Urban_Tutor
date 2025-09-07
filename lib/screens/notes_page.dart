// lib/screens/notes_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_card.dart';
import '../services/auth_service_ns.dart';
import '../auth/login_screen_ns.dart';
import 'add_notes_page.dart';

class NotesPage extends StatefulWidget {
  final String grade;

  const NotesPage({super.key, required this.grade});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with AutomaticKeepAliveClientMixin {
  String selectedSubject = 'All';
  String selectedDifficulty = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // User data
  String? userName;
  String? userEmail;
  bool isLoggedIn = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotes();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final credentials = await AuthServiceNs.getStoredCredentials();
      final isTokenValid = await AuthServiceNs.isTokenValid();
      
      setState(() {
        isLoggedIn = isTokenValid;
        userName = credentials['username'];
        userEmail = credentials['email'];
      });
    } catch (e) {
      setState(() {
        isLoggedIn = false;
        userName = null;
        userEmail = null;
      });
    }
  }

  Future<void> _refreshNotes() async {
    final provider = context.read<NotesProvider>();
    provider.setGrade(widget.grade);
    await provider.fetchNotes(grade: widget.grade);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Safe method to get user initials
  String _getUserInitial(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'U'; // Default to 'U' for User
    }
    return name.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Responsive breakpoints
    final isPhone = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive padding
    final horizontalPadding = isDesktop ? 48.0 : isTablet ? 32.0 : 16.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    
    // Responsive font sizes
    final titleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final bodyFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grade ${widget.grade} Notes',
          style: TextStyle(fontSize: titleFontSize),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: isDesktop ? 2 : 1,
        actions: [
          // Refresh button
          IconButton(
            onPressed: () async {
              await _refreshNotes();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            iconSize: isDesktop ? 28 : 24,
          ),
          // Clear filters button
          IconButton(
            onPressed: () async {
              final provider = context.read<NotesProvider>();
              provider.clearFilters();
              await provider.fetchNotes();
              setState(() {
                selectedSubject = 'All';
                selectedDifficulty = 'All';
                searchQuery = '';
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All Filters',
            iconSize: isDesktop ? 28 : 24,
          ),
          // Profile button
          PopupMenuButton<String>(
            icon: Icon(
              isLoggedIn ? Icons.account_circle : Icons.login,
              size: isDesktop ? 28 : 24,
            ),
            tooltip: 'Profile',
            onSelected: (value) async {
              switch (value) {
                case 'login':
                  await _navigateToLogin();
                  break;
                case 'logout':
                  await _showLogoutDialog();
                  break;
                case 'profile':
                  _showProfileDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!isLoggedIn) ...[
                PopupMenuItem<String>(
                  value: 'login',
                  child: Row(
                    children: [
                      Icon(Icons.login, size: isDesktop ? 20 : 18),
                      SizedBox(width: 8),
                      Text(
                        'Login',
                        style: TextStyle(fontSize: bodyFontSize),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, size: isDesktop ? 20 : 18),
                      SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: TextStyle(fontSize: bodyFontSize),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: isDesktop ? 20 : 18,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // User greeting (if logged in)
                if (isLoggedIn && userName != null && userName!.isNotEmpty) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: isDesktop ? 20 : 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          _getUserInitial(userName),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 16 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $userName!',
                              style: TextStyle(
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (userEmail != null && userEmail!.isNotEmpty)
                              Text(
                                userEmail!,
                                style: TextStyle(
                                  fontSize: bodyFontSize * 0.9,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
                
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: bodyFontSize),
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(fontSize: bodyFontSize),
                    prefixIcon: Icon(
                      Icons.search,
                      size: isDesktop ? 24 : 20,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: isDesktop ? 24 : 20,
                            ),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                _searchController.clear();
                              });
                              context.read<NotesProvider>().searchNotes('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 20 : 16,
                      vertical: isDesktop ? 16 : 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    context.read<NotesProvider>().searchNotes(value);
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

                // Filter Row - Responsive Layout
                isPhone
                    ? Column(
                        children: [
                          _buildSubjectDropdown(bodyFontSize, isDesktop),
                          SizedBox(height: screenHeight * 0.015),
                          _buildDifficultyDropdown(bodyFontSize, isDesktop),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: _buildSubjectDropdown(bodyFontSize, isDesktop)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDifficultyDropdown(bodyFontSize, isDesktop)),
                        ],
                      ),
              ],
            ),
          ),

          // Notes List
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: isDesktop ? 60 : isTablet ? 50 : 40,
                          height: isDesktop ? 60 : isTablet ? 50 : 40,
                          child: const CircularProgressIndicator(),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Loading notes...',
                          style: TextStyle(fontSize: bodyFontSize),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            size: isDesktop ? 80 : isTablet ? 60 : 50,
                            color: Colors.red,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Error: ${provider.errorMessage}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: bodyFontSize),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          ElevatedButton(
                            onPressed: () async {
                              await _refreshNotes();
                            },
                            child: Text(
                              'Retry',
                              style: TextStyle(fontSize: bodyFontSize),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Get filtered notes
                final notesToShow = provider.filteredNotes;

                if (notesToShow.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_add,
                            size: isDesktop ? 120 : isTablet ? 100 : 80,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Text(
                            'No notes found for Grade ${widget.grade}',
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Text(
                            searchQuery.isNotEmpty ||
                                    selectedSubject != 'All' ||
                                    selectedDifficulty != 'All'
                                ? 'Try adjusting your filters'
                                : 'Be the first to add a note!',
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToAddNote(),
                            icon: Icon(
                              Icons.add,
                              size: isDesktop ? 24 : 20,
                            ),
                            label: Text(
                              'Add Note',
                              style: TextStyle(fontSize: bodyFontSize),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 32 : isTablet ? 24 : 20,
                                vertical: isDesktop ? 16 : isTablet ? 14 : 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshNotes,
                  child: _buildNotesLayout(
                    notesToShow,
                    screenSize,
                    horizontalPadding,
                    isPhone,
                    isTablet,
                    isDesktop,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      // Floating Action Button - Responsive
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddNote(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: isDesktop ? 28 : 24,
        ),
        label: Text(
          'Add Note',
          style: TextStyle(
            color: Colors.white,
            fontSize: bodyFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        extendedPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 16,
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown(double fontSize, bool isDesktop) {
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<String>>(
          future: provider.getAvailableSubjects(),
          builder: (context, snapshot) {
            final subjects = snapshot.data ??
                ['All', 'Mathematics', 'Science', 'English', 'Physics'];
            if (!subjects.contains(selectedSubject)) {
              selectedSubject = 'All';
            }
            
            return DropdownButtonFormField<String>(
              value: selectedSubject,
              style: TextStyle(
                fontSize: fontSize,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: 'Subject',
                labelStyle: TextStyle(fontSize: fontSize),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 16 : 12,
                  vertical: isDesktop ? 16 : 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                ),
              ),
              items: subjects
                  .map((subject) => DropdownMenuItem(
                        value: subject,
                        child: Text(
                          subject,
                          style: TextStyle(fontSize: fontSize),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value!;
                });
                provider.setSubject(value!);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDifficultyDropdown(double fontSize, bool isDesktop) {
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        final difficulties = provider.getAvailableDifficulties();
        return DropdownButtonFormField<String>(
          value: selectedDifficulty,
          style: TextStyle(
            fontSize: fontSize,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            labelText: 'Difficulty',
            labelStyle: TextStyle(fontSize: fontSize),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 12,
              vertical: isDesktop ? 16 : 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
          ),
          items: difficulties
              .map((difficulty) => DropdownMenuItem(
                    value: difficulty,
                    child: Text(
                      difficulty,
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedDifficulty = value!;
            });
            provider.setDifficulty(value!);
          },
        );
      },
    );
  }

  Widget _buildNotesLayout(
    List notesToShow,
    Size screenSize,
    double horizontalPadding,
    bool isPhone,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isPhone) {
      // Mobile - Single column list
      return ListView.builder(
        padding: EdgeInsets.all(horizontalPadding),
        itemCount: notesToShow.length,
        itemBuilder: (context, index) {
          final note = notesToShow[index];
          return Padding(
            padding: EdgeInsets.only(bottom: screenSize.height * 0.015),
            child: NoteCard(
              note: note,
              onTap: () => _viewNoteDetails(note), // Enhanced view function
              onDelete: () => _deleteNote(note),
              onDownload: () => _downloadNote(note),
            ),
          );
        },
      );
    } else {
      // Tablet/Desktop - Grid layout
      final crossAxisCount = isDesktop ? 3 : 2;
      final childAspectRatio = isDesktop ? 2.8 : isTablet ? 2.2 : 2.0;
      
      return GridView.builder(
        padding: EdgeInsets.all(horizontalPadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isDesktop ? 24 : 16,
          mainAxisSpacing: isDesktop ? 24 : 16,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: notesToShow.length,
        itemBuilder: (context, index) {
          final note = notesToShow[index];
          return NoteCard(
            note: note,
            onTap: () => _viewNoteDetails(note), // Enhanced view function
            onDelete: () => _deleteNote(note),
            onDownload: () => _downloadNote(note),
          );
        },
      );
    }
  }

  // ENHANCED VIEW NOTE DETAILS DIALOG
  void _viewNoteDetails(dynamic note) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 1200 ? 0.5 :
                      screenSize.width > 800 ? 0.6 :
                      screenSize.width > 600 ? 0.7 : 0.9;
    
    // Get current user info for comparison
    final currentUser = FirebaseAuth.instance.currentUser;
    final isMyNote = currentUser != null && note.uploadedBy == currentUser.uid;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: screenSize.width * dialogWidth,
          constraints: BoxConstraints(
            maxHeight: screenSize.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with large icon and close button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Note Details',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Large subject icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        _getSubjectIcon(note.category),
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      note.fileName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description section
                      if (note.description != null && note.description!.isNotEmpty) ...[
                        _buildSectionHeader(Icons.description, 'Description'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            note.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Basic Information section
                      _buildSectionHeader(Icons.info_outline, 'Basic Information'),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildDetailRow(Icons.school, 'Grade', 'Grade ${note.grade}'),
                        _buildDetailRow(Icons.subject, 'Subject', note.category),
                        _buildDetailRow(Icons.trending_up, 'Difficulty', note.difficulty, 
                          difficultyColor: _getDifficultyColor(note.difficulty)),
                        _buildDetailRow(Icons.public, 'Visibility', 
                          note.isPublic ? 'Public' : 'Private',
                          valueColor: note.isPublic ? Colors.green : Colors.orange),
                      ]),
                      const SizedBox(height: 20),
                      
                      // File Information section
                      _buildSectionHeader(Icons.insert_drive_file, 'File Information'),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildDetailRow(Icons.text_snippet, 'File Type', 
                          note.fileType?.toUpperCase() ?? 'Text Note'),
                        _buildDetailRow(Icons.data_usage, 'File Size', note.formattedFileSize),
                        if (note.fileUrl != null && note.fileUrl!.isNotEmpty)
                          _buildDetailRow(Icons.link, 'Has Attachment', 'Yes', 
                            valueColor: Colors.green),
                      ]),
                      const SizedBox(height: 20),
                      
                      // Upload Information section
                      _buildSectionHeader(Icons.cloud_upload, 'Upload Information'),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildDetailRow(Icons.person, 'Uploaded by', 
                          isMyNote ? 'You' : 'Another User',
                          valueColor: isMyNote ? Colors.blue : Colors.grey),
                        _buildDetailRow(Icons.calendar_today, 'Upload Date', 
                          _formatDate(note.uploadedAt)),
                        _buildDetailRow(Icons.access_time, 'Upload Time', 
                          _formatTime(note.uploadedAt)),
                        _buildDetailRow(Icons.fingerprint, 'Note ID', 
                          note.id?.substring(0, 8) ?? 'Unknown'),
                      ]),
                      const SizedBox(height: 20),
                      
                      // Tags section
                      if (note.tags != null && note.tags.isNotEmpty) ...[
                        _buildSectionHeader(Icons.local_offer, 'Tags'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: note.tags.map<Widget>((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // Statistics section
                      _buildSectionHeader(Icons.analytics, 'Statistics'),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildDetailRow(Icons.download, 'Downloads', '0'), // You can track this
                        _buildDetailRow(Icons.visibility, 'Views', '0'), // You can track this
                        _buildDetailRow(Icons.favorite, 'Favorites', '0'), // You can track this
                      ]),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _downloadNote(note);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _shareNote(note);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (isMyNote) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteNote(note);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, 
      {Color? valueColor, Color? difficultyColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (difficultyColor != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: difficultyColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: valueColor != null ? FontWeight.w500 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'math':
        return Icons.calculate;
      case 'science':
      case 'physics':
      case 'chemistry':
      case 'biology':
        return Icons.science;
      case 'english':
      case 'literature':
        return Icons.menu_book;
      case 'history':
        return Icons.history_edu;
      case 'geography':
        return Icons.public;
      default:
        return Icons.description;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  void _shareNote(dynamic note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Sharing ${note.fileName}...')),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNotesPage(
          initialGrade: widget.grade,
        ),
      ),
    );

    // Force refresh when returning
    if (result != null && result['success'] == true) {
      await _refreshNotes();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Note added to Grade ${result['grade']}!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
    
    // Refresh user data after login
    await _loadUserData();
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthServiceNs.logout();
      await _loadUserData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.logout, color: Colors.white),
                SizedBox(width: 8),
                Text('Logged out successfully'),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showProfileDialog() {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 600 ? 400.0 : screenSize.width * 0.9;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _getUserInitial(userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName ?? 'Unknown User',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (userEmail != null && userEmail!.isNotEmpty)
                Text(
                  userEmail!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showLogoutDialog();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteNote(note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<NotesProvider>().deleteNote(note.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Note deleted successfully'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting note: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _downloadNote(note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Downloading ${note.fileName}...')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
