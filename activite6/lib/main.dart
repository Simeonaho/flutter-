import 'package:flutter/material.dart';
import 'Modele/Redacteur.dart'; // Importation du modèle Redacteur


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseManager().initialize(); // init DB
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Notes',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const LoginPage(),
    );
  }
}

// ----------------- PAGE LOGIN -----------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = "";

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
        setState(() => _message = "Veuillez remplir tous les champs !");
        return;
      }

    final user = await DatabaseManager().getUserByUsername(username);

    if (user != null && user.password == password) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NotesPage()),
      );
    } else {
      setState(() {
        _message = "Identifiants incorrects !";
      });
    }
  }

void _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _message = "Veuillez remplir tous les champs !");
      return;
    }

    await DatabaseManager().insertUser(
      User(username: username, password: password),
    );

    setState(() {
      _message = "Utilisateur créé ";
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NotesPage()),
    );
  }

 
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Nom d'utilisateur")),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mot de passe")),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _login,
              icon: const Icon(Icons.login),
              label: const Text("Se connecter"),
            ),
            TextButton.icon(
              onPressed: _register,
              icon: const Icon(Icons.person_add),
              label: const Text("Créer un compte"),
            ),
            const SizedBox(height: 10),
            Text(_message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

// ----------------- PAGE NOTES -----------------
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final notes = await DatabaseManager().getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  void _addNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Titre")),
            TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Contenu")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton.icon(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                await DatabaseManager().insertNote(
                  Note(
                      title: titleController.text,
                      content: contentController.text),
                );
                _loadNotes();
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _editNoteDialog(Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier la note"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Titre")),
            TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Contenu")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton.icon(
            onPressed: () async {
              await DatabaseManager().updateNote(
                Note(
                    id: note.id,
                    title: titleController.text,
                    content: contentController.text),
              );
              _loadNotes();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
            label: const Text("Mettre à jour"),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int id) async {
    await DatabaseManager().deleteNote(id);
    _loadNotes();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Déconnexion",
            onPressed: _logout,
          ),
        ],
      ),
      body: _notes.isEmpty
          ? const Center(child: Text("Aucune note pour le moment."))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.note, color: Colors.pink),
                    title: Text(note.title),
                    subtitle: Text(note.content),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editNoteDialog(note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(note.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
