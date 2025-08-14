import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:table_calendar/table_calendar.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassBuddy - Login & Signup App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
    );
  }
}

// Task Model
class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  Priority priority;
  DateTime createdAt;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    required this.createdAt,
    this.dueDate,
  });

  Map<String, dynamic> toMap() { //task to firebase
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'date': dueDate?.toIso8601String().substring(0, 10),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) { //firebase to task
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      priority: Priority.values.firstWhere((p) => p.name == map['priority']),
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }
}


enum Priority {
  low,
  medium,
  high,
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Simple email validation using regex
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      setState(() {
        _isLoading = true;
      });

      try {
        User? user = await _authService.signInWithEmailPassword(email, password);
        
        if (user != null) {
          // Clear text fields after successful login
          _emailController.clear();
          _passwordController.clear();

          // Navigate to home screen on successful login
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(builder: (BuildContext context) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _signUp() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color(0xff003f5b),
              Color(0xff2b4b7d),
              Color(0xff5f5195),
              Color(0xff98509d),
              Color(0xffcc4c91),
              Color(0xfff25375),
              Color(0xffff6f4e),
              Color(0xffff9913),
            ], // Gradient from https://learnui.design/tools/gradient-generator.html
            tileMode: TileMode.mirror,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // To center the icon horizontally
          children: <Widget>[
            const SizedBox(height: 70.0), // Padding from top for the icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.calculate_outlined,
                  size: 60,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.analytics,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.assistant,
                  size: 150,
                  color: Colors.grey[50],
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.auto_stories,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.calendar_month,
                  size: 60,
                  color: Colors.grey[500],
                ),
              ],
            ),
            const SizedBox(height: 24.8), 
            Expanded(
              child: Stack( // Use Stack to layer background elements and content
                children: <Widget>[
                  // Layer 1: White background with purple border
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(52)),
                      border: Border.all(color: Colors.purple, width: 2.0),
                    ),
                  ),
                  // Layer 2: Main content (form)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 48.0), // Added to lower the contents position
                          const Text(
                            'Welcome to ClassBuddy',
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          const SizedBox(height: 48.0),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              prefixIcon: const Icon(Icons.email),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            obscureText: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 30.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 20.0), // Space between Login and Sign Up buttons
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Forgot password? Not implemented'),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      setState(() {
        _isLoading = true;
      });

      try {
        User? user = await _authService.signUpWithEmailPassword(email, password);
        
        if (user != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful for $email!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear fields after successful sign-up
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();

          // Navigate to home screen after successful signup
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(builder: (BuildContext context) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_authService.getErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xff003f5b),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color(0xff003f5b),
              Color(0xff2b4b7d),
              Color(0xff5f5195),
              Color(0xff98509d),
              Color(0xffcc4c91),
              Color(0xfff25375),
              Color(0xffff6f4e),
              Color(0xffff9913),
            ], // Gradient from https://learnui.design/tools/gradient-generator.html
            tileMode: TileMode.mirror,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.calculate_outlined,
                  size: 60,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.analytics,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.assistant,
                  size: 150,
                  color: Colors.grey[50],
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.auto_stories,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.calendar_month,
                  size: 60,
                  color: Colors.grey[500],
                ),
              ],
            ),
            const SizedBox(height: 24.8),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(52)),
                      border: Border.all(color: Colors.purple, width: 2.0),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 48.0),
                          const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 48.0),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              prefixIcon: const Icon(Icons.email),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            obscureText: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 20.0),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            obscureText: true,
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 30.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Sign Up'),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Go back to LoginScreen
                            },
                            child: Text(
                              'Already have an account? Login',
                              style: TextStyle(color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedTime;

  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasksForSelectedDay();
  }

  Future<void> _loadTasksForSelectedDay() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || _selectedDay == null) return;

    final selectedDateStr = _selectedDay!.toIso8601String().substring(0, 10);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('date', isEqualTo: selectedDateStr)
        .get();

    setState(() {
      _tasks = snapshot.docs
          .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Task Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null || _selectedDay == null) return;

              final docRef = FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('tasks')
                  .doc();

              final newTask = Task(
                id: docRef.id,
                title: controller.text.trim(),
                createdAt: DateTime.now(),
                dueDate: _selectedDay,
                priority: Priority.medium,
              );

              await docRef.set(newTask.toMap());

              if (context.mounted) Navigator.pop(context);
              _loadTasksForSelectedDay();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .delete();

    _loadTasksForSelectedDay();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Calendar',
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadTasksForSelectedDay();
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks for this day.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ListTile(
                        title: Text(task.title),
                        subtitle: task.dueDate != null
                            ? Text('Due: ${task.dueDate!.toIso8601String().substring(0, 10)}')
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Task> tasks = [];
  String _filterStatus = 'All'; // All, Completed, Pending
  Priority? _filterPriority;
  StreamSubscription? _taskSubscription;

  @override
  void initState() {
    super.initState();
    _loadTasksFromFirestore();;
  }
  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }

  
  void _loadTasksFromFirestore() {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  _taskSubscription = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .snapshots()
      .listen((snapshot) {
    setState(() {
      tasks = snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
    });
  });
}

  void _toggleTaskCompletion(String taskId) {
  final taskIndex = tasks.indexWhere((task) => task.id == taskId);
  if (taskIndex == -1) return;

  final task = tasks[taskIndex];
  task.isCompleted = !task.isCompleted;

  // Update in Firestore
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': task.isCompleted});
  }

  // Update UI
  setState(() {
    tasks[taskIndex] = task;
  });
}

  List<Task> get _filteredTasks {
    List<Task> filtered = tasks;

    // Filter by status
    if (_filterStatus == 'Completed') {
      filtered = filtered.where((task) => task.isCompleted).toList();
    } else if (_filterStatus == 'Pending') {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }

    // Filter by priority
    if (_filterPriority != null) {
      filtered = filtered.where((task) => task.priority == _filterPriority).toList();
    }

    return filtered;
  }

  void _addTask(Task task) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(task.id)
      .set(task.toMap());
}


  void _updateTask(Task task) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(task.id)
      .update(task.toMap());
}

  void _deleteTask(String taskId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('tasks')
      .doc(taskId)
      .delete();
}

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;
    final filteredTasks = _filteredTasks;

    return MainScaffold(
      title: 'List',
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await _logout(context, authService);
          },
        ),
      ],
      body: Column(
        children: [
          // User Info Card
          

          // Task Statistics
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Tasks',
                    tasks.length.toString(),
                    Icons.assignment,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    tasks.where((t) => t.isCompleted).length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    tasks.where((t) => !t.isCompleted).length.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['All', 'Completed', 'Pending'].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _filterStatus = value ?? 'All';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: DropdownButtonFormField<Priority?>(
                        value: _filterPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<Priority?>(
                            value: null,
                            child: Text('All Priorities'),
                          ),
                          ...Priority.values.map((Priority priority) {
                            return DropdownMenuItem<Priority?>(
                              value: priority,
                              child: Text(priority.displayName),
                            );
                          }).toList(),
                        ],
                        onChanged: (Priority? value) {
                          setState(() {
                            _filterPriority = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 80.0,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          tasks.isEmpty
                              ? 'No tasks yet!\nTap + to add your first task'
                              : 'No tasks match your filters',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.0),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: InkWell(
          onTap: () => _toggleTaskCompletion(task.id),
          child: Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? Colors.green : Colors.grey,
                width: 2.0,
              ),
              color: task.isCompleted ? Colors.green : Colors.transparent,
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16.0)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text(
                task.description,
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey : Colors.grey.shade600,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
            const SizedBox(height: 8.0),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: task.priority.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: task.priority.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    task.priority.displayName,
                    style: TextStyle(
                      color: task.priority.color,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 8.0),
                  Icon(
                    Icons.schedule,
                    size: 14.0,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    _formatDate(task.dueDate!),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String action) {
            switch (action) {
              case 'edit':
                _showEditTaskDialog(task);
                break;
              case 'delete':
                _showDeleteConfirmation(task);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18.0),
                  SizedBox(width: 8.0),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18.0, color: Colors.red),
                  SizedBox(width: 8.0),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1) return 'In $difference days';
    return '${-difference} days ago';
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => TaskDialog(
        onSave: _addTask,
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) => TaskDialog(
        task: task,
        onSave: _updateTask,
      ),
    );
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteTask(task.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task "${task.title}" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthService authService) async {
  try {
    await _taskSubscription?.cancel(); // Cancel the Firestore stream
    await authService.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error logging out. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}

// Task Dialog for Add/Edit
class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late Priority _selectedPriority;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedPriority = widget.task?.priority ?? Priority.medium;
    _selectedDueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<Priority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: Priority.values.map((Priority priority) {
                  return DropdownMenuItem<Priority>(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: priority.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(priority.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (Priority? value) {
                  setState(() {
                    _selectedPriority = value ?? Priority.medium;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDueDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date (Optional)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDueDate == null
                        ? 'No due date set'
                        : _formatDate(_selectedDueDate!),
                  ),
                ),
              ),
              if (_selectedDueDate != null) ...[
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDueDate = null;
                    });
                  },
                  child: const Text('Remove due date'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final task = Task(
                id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                priority: _selectedPriority,
                createdAt: widget.task?.createdAt ?? DateTime.now(),
                dueDate: _selectedDueDate,
                isCompleted: widget.task?.isCompleted ?? false,
              );
              
              widget.onSave(task);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.task == null ? 'Task added successfully!' : 'Task updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: Text(widget.task == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Settings',
      body: const Center(
        child: Text(
          'Adjust your settings here.',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Chats',
      body: const Center(
        child: Text(
          'Engage in conversations here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(builder: (BuildContext context) => const CreateGroupChatScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _memberEmailController = TextEditingController();
  final List<String> _membersList = <String>[];

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

  String? _validateGroupName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a group chat name';
    }
    return null;
  }

  String? _validateMemberEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final RegExp emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _addMember() {
    final String email = _memberEmailController.text.trim();
    String? validationError = _validateMemberEmail(email);

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }

    if (email.isNotEmpty && !_membersList.contains(email)) {
      setState(() {
        _membersList.add(email);
      });
      _memberEmailController.clear();
    } else if (_membersList.contains(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member already added!'), backgroundColor: Colors.orange),
      );
    }
  }

  void _removeMember(String email) {
    setState(() {
      _membersList.remove(email);
    });
  }

  void _createGroupChat() {
    if (_formKey.currentState!.validate()) {
      final String groupName = _groupNameController.text;

      if (_membersList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one member to the group.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Simulate creating a group chat - Here you would integrate with Firebase or your backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group chat "$groupName" with members ${_membersList.join(', ')} created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to ChatScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group Chat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Chat Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: const Icon(Icons.group),
                ),
                validator: _validateGroupName,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _memberEmailController,
                decoration: InputDecoration(
                  labelText: 'Member Email',
                  hintText: 'Add members one by one',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: const Icon(Icons.email),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: _addMember,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (String value) => _addMember(), // Allow adding on submit
              ),
              const SizedBox(height: 10.0),
              if (_membersList.isNotEmpty) ...<Widget>[
                const Text(
                  'Group Members:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _membersList.map<Widget>((String email) {
                    return Chip(
                      label: Text(email),
                      onDeleted: () => _removeMember(email),
                      deleteIcon: const Icon(Icons.cancel, size: 18),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20.0),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createGroupChat,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Create Group Chat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions
      print('Sign up error: ${e.message}');
      throw e;
    } catch (e) {
      print('Sign up error: $e');
      throw e;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions
      print('Sign in error: ${e.message}');
      throw e;
    } catch (e) {
      print('Sign in error: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw e;
    }
  }

  // Get user authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get error message from FirebaseAuthException
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const MainScaffold({
    super.key, 
    required this.title, 
    required this.body,
    this.floatingActionButton,
    this.actions});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;
    final List<String> drawerItems = const [
      'Home',
      'List',
      'Chats',
      'Settings',
      'Logout',
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 10),
                  if (user != null)
                    Text('Welcome, ${user.email}!',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            ...drawerItems.map((String item) => ListTile(
              leading: _getIcon(item),
              title: Text(item),
              onTap: () => _handleNavigation(context, item, authService),
            )),
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Icon _getIcon(String item) {
    switch (item) {
      case 'Home': return const Icon(Icons.home);
      case 'List': return const Icon(Icons.list);
      case 'Chats': return const Icon(Icons.chat);
      case 'Settings': return const Icon(Icons.settings);
      case 'Logout': return const Icon(Icons.logout);
      default: return const Icon(Icons.info);
    }
  }

  void _handleNavigation(BuildContext context, String item, AuthService authService) async {
    Navigator.pop(context); // Close drawer

    switch (item) {
      case 'Home':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 'List':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()));
        break;
      case 'Chats':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()));
        break;
      case 'Settings':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()));
        break;
      case 'Logout':
        await authService.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        break;
    }
  }
}
