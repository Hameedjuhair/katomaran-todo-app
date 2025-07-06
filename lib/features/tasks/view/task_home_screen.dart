import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/services/auth_service.dart';
import '../../auth/view/login_screen.dart';
import '../view_model/task_provider.dart';
import '../model/task.dart';

class TaskHomeScreen extends ConsumerStatefulWidget {
  const TaskHomeScreen({super.key});

  @override
  ConsumerState<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends ConsumerState<TaskHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);

    final filteredTasks = tasks
        .where((task) =>
            task.title.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    final completedTasks =
        filteredTasks.where((task) => task.isCompleted).toList();
    final pendingTasks =
        filteredTasks.where((task) => !task.isCompleted).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Tasks'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Completed'),
              Tab(text: 'Pending'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(ref, filteredTasks),
                  _buildTaskList(ref, completedTasks),
                  _buildTaskList(ref, pendingTasks),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskList(WidgetRef ref, List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks found'));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (_, index) {
        final task = tasks[index];
        return ListTile(
          onTap: () => _showEditDialog(context, ref, task),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          subtitle: Text(
              '${task.description}\nDue: ${DateFormat.yMMMd().format(task.dueDate)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  task.isCompleted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.green,
                ),
                onPressed: () {
                  ref.read(taskListProvider.notifier).toggleComplete(task.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Task?'),
                      content: const Text(
                          'Are you sure you want to delete this task?'),
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
                  if (confirm == true) {
                    ref.read(taskListProvider.notifier).deleteTask(task.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    DateTime selectedDate = task.dueDate;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) selectedDate = picked;
              },
              child: const Text('Pick New Due Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descController.text.isNotEmpty) {
                ref.read(taskListProvider.notifier).editTask(
                      task.id,
                      titleController.text,
                      descController.text,
                      selectedDate,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) selectedDate = picked;
              },
              child: const Text('Pick Due Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  descController.text.isNotEmpty &&
                  selectedDate != null) {
                ref.read(taskListProvider.notifier).addTask(
                      titleController.text,
                      descController.text,
                      selectedDate!,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
