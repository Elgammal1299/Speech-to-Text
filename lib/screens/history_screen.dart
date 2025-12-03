import 'package:flutter/material.dart';
import '../models/voice_note.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import 'note_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final bool showAppBar;

  const HistoryScreen({super.key, this.showAppBar = true});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  List<VoiceNote> _notes = [];
  List<VoiceNote> _filteredNotes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterLanguage = 'All';
  String _sortBy = 'date'; // date, title, duration

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _storageService.getAllNotes();
    setState(() {
      _notes = notes;
      _filteredNotes = notes;
      _isLoading = false;
    });
  }

  void _filterNotes() {
    setState(() {
      _filteredNotes = _notes.where((note) {
        final searchText = '${note.title.toLowerCase()} ${note.text?.toLowerCase() ?? ''}';
        final matchesSearch = searchText.contains(_searchQuery.toLowerCase());
        final matchesCategory =
            _filterLanguage == 'All' || (note.category ?? 'Uncategorized') == _filterLanguage;
        return matchesSearch && matchesCategory;
      }).toList();

      // Apply sorting
      _sortNotes();
    });
  }

  void _sortNotes() {
    switch (_sortBy) {
      case 'title':
        _filteredNotes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'duration':
        _filteredNotes.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case 'date':
      default:
        _filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: widget.showAppBar
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text(
                'History',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, color: Colors.black87),
                  tooltip: 'Sort by',
                  onSelected: (value) {
                    setState(() => _sortBy = value);
                    _filterNotes();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'date',
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: _sortBy == 'date' ? Colors.blue : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: _sortBy == 'date' ? FontWeight.bold : FontWeight.normal,
                              color: _sortBy == 'date' ? Colors.blue : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'title',
                      child: Row(
                        children: [
                          Icon(
                            Icons.title,
                            size: 16,
                            color: _sortBy == 'title' ? Colors.blue : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Title',
                            style: TextStyle(
                              fontWeight: _sortBy == 'title' ? FontWeight.bold : FontWeight.normal,
                              color: _sortBy == 'title' ? Colors.blue : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'duration',
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: _sortBy == 'duration' ? Colors.blue : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Duration',
                            style: TextStyle(
                              fontWeight: _sortBy == 'duration' ? FontWeight.bold : FontWeight.normal,
                              color: _sortBy == 'duration' ? Colors.blue : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.black87),
                  tooltip: 'Filter by category',
                  onSelected: (value) {
                    setState(() => _filterLanguage = value);
                    _filterNotes();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'All', child: Text('All Categories')),
                    const PopupMenuItem(value: 'Uncategorized', child: Text('Uncategorized')),
                    ...Categories.all.map((category) => PopupMenuItem(
                      value: category.name,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 16, color: category.color),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    )),
                  ],
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNotes.isEmpty
                    ? _buildEmptyState()
                    : _buildNotesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _filterNotes();
        },
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                    _filterNotes();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No notes yet' : 'No notes found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Start recording to save notes'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildNoteCard(VoiceNote note) {
    final categoryColor = note.category != null
        ? Categories.getColor(note.category)
        : Colors.grey;

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await _storageService.deleteNote(note.id);
        _loadNotes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Note deleted successfully'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // TODO: Implement undo functionality
                },
              ),
            ),
          );
        }
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_forever,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            categoryColor.withValues(alpha: 0.02),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteDetailScreen(note: note),
              ),
            );
            _loadNotes();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.audiotrack, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    note.formattedDuration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          note.formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                note.preview,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.category != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Categories.getColor(note.category).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Categories.getColor(note.category).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Categories.getIcon(note.category),
                        size: 14,
                        color: Categories.getColor(note.category),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        note.category!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Categories.getColor(note.category),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}
