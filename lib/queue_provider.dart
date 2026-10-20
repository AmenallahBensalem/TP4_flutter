import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/client.dart';

class QueueProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Client> _clients = [];
  List<Client> get clients => _clients;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  QueueProvider() {
    _listen();
  }

  void _listen() {
    _sub = _supabase
        .from('clients')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .listen(
      (rows) {
        _clients = rows.map(Client.fromMap).toList();
        notifyListeners();
      },
      onError: (e) => debugPrint('Stream error: $e'),
    );
  }

  Future<void> addClient(String name) async {
    if (name.trim().isEmpty) return;
    try {
      await _supabase.from('clients').insert({'name': name.trim()});
    } on PostgrestException catch (e) {
      debugPrint('Add failed: ${e.message}');
    }
  }

  Future<void> removeClient(String id) async {
    try {
      await _supabase.from('clients').delete().eq('id', id);
    } on PostgrestException catch (e) {
      debugPrint('Remove failed: ${e.message}');
    }
  }

  Future<void> nextClient() async {
    if (_clients.isEmpty) return;
    await removeClient(_clients.first.id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}