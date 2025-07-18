// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:graphql_infra_tool_example/services/graphql_servcie.dart';
import 'models/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraphQL Infrastructure Tool Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GraphQLService _graphQLService = GraphQLService();
  List<User> users = [];
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);

    final result = await _graphQLService.getUsers();

    result.when(
      onSuccess: (data) {
        setState(() {
          users = data;
          isLoading = false;
          errorMessage = null;
        });
      },
      onFailure: (error) {
        setState(() {
          errorMessage = error.message;
          isLoading = false;
        });
      },
    );
  }

  Future<void> _createUser() async {
    final input = CreateUserInput(name: 'John Doe', email: 'john@example.com');

    final result = await _graphQLService.createUser(input);

    result.when(
      onSuccess: (user) {
        setState(() {
          users.add(user);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User created successfully!')));
      },
      onFailure: (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${error.message}')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GraphQL Example'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadUsers)],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
        tooltip: 'Create User',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUsers, child: Text('Retry')),
          ],
        ),
      );
    }

    if (users.isEmpty) {
      return Center(child: Text('No users found'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(user.name.substring(0, 1).toUpperCase()),
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteUser(user.id),
          ),
        );
      },
    );
  }

  Future<void> _deleteUser(String userId) async {
    final result = await _graphQLService.deleteUser(userId);

    result.when(
      onSuccess: (success) {
        setState(() {
          users.removeWhere((user) => user.id == userId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User deleted successfully!')));
      },
      onFailure: (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${error.message}')));
      },
    );
  }
}
