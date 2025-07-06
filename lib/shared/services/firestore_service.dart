// lib/shared/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/tasks/model/task.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Task>> getTasks(String? userId) {
    if (userId == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Task(
                id: doc.id,
                title: data['title'],
                description: data['description'],
                dueDate: (data['dueDate'] as Timestamp).toDate(),
                isCompleted: data['isCompleted'],
              );
            }).toList());
  }

  Future<void> addTask(String userId, Task task) async {
    await _db.collection('users').doc(userId).collection('tasks').add({
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate,
      'isCompleted': task.isCompleted,
    });
  }

  Future<void> updateTask(String userId, Task task) async {
    await _db.collection('users').doc(userId).collection('tasks').doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate,
    });
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _db.collection('users').doc(userId).collection('tasks').doc(taskId).delete();
  }

  Future<void> toggleComplete(String userId, String taskId, bool isCompleted) async {
    await _db.collection('users').doc(userId).collection('tasks').doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }
}
