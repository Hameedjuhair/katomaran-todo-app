// lib/features/tasks/view_model/task_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/task.dart';
import 'package:uuid/uuid.dart';

final taskListProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) => TaskNotifier());

class TaskNotifier extends StateNotifier<List<Task>> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  TaskNotifier() : super([]) {
    if (userId != null) {
      _loadTasks();
    }
  }

  void _loadTasks() {
    firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('dueDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return Task(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          dueDate: (data['dueDate'] as Timestamp).toDate(),
          isCompleted: data['isCompleted'],
        );
      }).toList();

      state = tasks;
    });
  }

  void addTask(String title, String description, DateTime dueDate) {
    if (userId == null) return;

    final taskId = const Uuid().v4();
    firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .set({
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'isCompleted': false,
    });
  }

  void toggleComplete(String id) {
    if (userId == null) return;

    final task = state.firstWhere((task) => task.id == id);
    firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(id)
        .update({'isCompleted': !task.isCompleted});
  }

  void deleteTask(String id) {
    if (userId == null) return;

    firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  void editTask(
    String id,
    String newTitle,
    String newDescription,
    DateTime newDate,
  ) {
    if (userId == null) return;

    firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(id)
        .update({
      'title': newTitle,
      'description': newDescription,
      'dueDate': newDate,
    });
  }
}
