import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Urban Tutor Classroom',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement classroom creation/joining logic
              _showClassroomOptionsBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement more options
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stream', icon: Icon(Icons.stream)),
            Tab(text: 'Classwork', icon: Icon(Icons.assignment)),
            Tab(text: 'People', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStreamTab(),
          _buildClassworkTab(),
          _buildPeopleTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add new post/assignment
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  Widget _buildStreamTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAnnouncementCard(),
        const SizedBox(height: 16),
        _buildClassworkSummaryCard(),
        const SizedBox(height: 16),
        _buildRecentActivityCard(),
      ],
    );
  }

  Widget _buildAnnouncementCard() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.announcement, color: Colors.white),
        ),
        title: const Text('Class Announcement'),
        subtitle: const Text('Important update for all students'),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Show more options
          },
        ),
      ),
    );
  }

  Widget _buildClassworkSummaryCard() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Upcoming Classwork',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Math Assignment'),
            subtitle: const Text('Due in 3 days'),
            trailing: TextButton(
              onPressed: () {
                // TODO: Navigate to assignment details
              },
              child: const Text('View'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Science Quiz'),
            subtitle: const Text('Due tomorrow'),
            trailing: TextButton(
              onPressed: () {
                // TODO: Navigate to quiz
              },
              child: const Text('Start'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const ListTile(
            leading: CircleAvatar(
              child: Text('TS'),
            ),
            title: Text('Teacher Smith'),
            subtitle: Text('Posted a new assignment: Chapter 5 Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassworkTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildClassworkSection('Assignments'),
        _buildClassworkSection('Quizzes'),
        _buildClassworkSection('Materials'),
      ],
    );
  }

  Widget _buildClassworkSection(String title) {
    return ExpansionTile(
      title: Text(title),
      children: [
        ListTile(
          title: Text('$title Item 1'),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              // TODO: Open specific item
            },
          ),
        ),
        ListTile(
          title: Text('$title Item 2'),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              // TODO: Open specific item
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeopleTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTeacherSection(),
        const SizedBox(height: 16),
        _buildStudentSection(),
      ],
    );
  }

  Widget _buildTeacherSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Teachers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const ListTile(
            leading: CircleAvatar(
              child: Text('TS'),
            ),
            title: Text('Teacher Smith'),
            subtitle: Text('Lead Instructor'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Students',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const ListTile(
            leading:  CircleAvatar(
              child: Text('JD'),
            ),
            title:  Text('John Doe'),
          ),
          const ListTile(
            leading:  CircleAvatar(
              child: Text('SA'),
            ),
            title:  Text('Sarah Anderson'),
          ),
        ],
      ),
    );
  }

  void _showClassroomOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create Classroom'),
                onTap: () {
                  // TODO: Implement classroom creation
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.join_inner),
                title: const Text('Join Classroom'),
                onTap: () {
                  // TODO: Implement classroom joining
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}