import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'queue_provider.dart';

class WaitingRoomApp extends StatelessWidget {
  const WaitingRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waiting Room',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WaitingRoomPage(),
    );
  }
}

class WaitingRoomPage extends StatefulWidget {
  const WaitingRoomPage({super.key});
  @override
  State<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  final _controller = TextEditingController();

  void _add() {
    context.read<QueueProvider>().addClient(_controller.text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting Room'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Enter name'),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _add, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<QueueProvider>(
                builder: (context, provider, _) {
                  if (provider.clients.isEmpty) {
                    return const Center(child: Text('No one in queue yet...'));
                  }
                  return ListView.builder(
                    itemCount: provider.clients.length,
                    itemBuilder: (context, i) {
                      final c = provider.clients[i];
                      return Card(
                        child: ListTile(
                          title: Text(c.name),
                          subtitle: Text(c.createdAt.toString().split(' ')[0]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => provider.removeClient(c.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.read<QueueProvider>().nextClient(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Client'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}