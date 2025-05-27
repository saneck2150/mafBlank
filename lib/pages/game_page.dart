import 'package:flutter/material.dart';
import 'dart:async';                    // ← для Timer
import 'package:flutter/services.dart'; // ← для Clipboard

class Player {
  final int number;
  String name;
  int fouls;
  int techFouls;

  Player({required this.number, required this.name})
      : fouls = 0,
        techFouls = 0;
}

// ---------------------- ОСНОВНАЯ СТРАНИЦА ---------------
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // ------------------- ДАННЫЕ ИГРОКОВ -------------------
  final List<Player> players = List.generate(
    10,
    (i) => Player(number: i + 1, name: 'Player ${i + 1}'),
  );

  // --- выставленные на голосование (в порядке добавления) ---
  final List<int> nominations = <int>[];

  // --- голоса: {номер игрока : [раунд1, раунд2, раунд3]} ---
  final Map<int, List<int>> votes = {};

  int currentRound = 0; // 0‑based: 0 → 1й, 1 → 2й, 2 → 3й

  final _bestMoveCtrl   = TextEditingController();
  final _killOrderCtrl  = TextEditingController();

  final List<String> _logs = [];                 // журнал

void _saveRoundToLog() {
  if (nominations.isEmpty) return;             // нечего сохранять

  final sb = StringBuffer()
    ..writeln('=== Раунд ${_logs.length + 1} ===')
    ..writeln('Выставлены: ${nominations.join(", ")}');

  for (final num in nominations) {
    final v = votes[num] ?? [0, 0, 0];
    sb.writeln('  Игрок $num  →  ${v[0]}/${v[1]}/${v[2]} голосов');
  }

  if (_bestMoveCtrl.text.isNotEmpty) {
    sb.writeln('Лучший ход: ${_bestMoveCtrl.text}');
  }
  if (_killOrderCtrl.text.isNotEmpty) {
    sb.writeln('Порядок отстрелов: ${_killOrderCtrl.text}');
  }
  sb.writeln();                                // пустая строка-разделитель

  setState(() => _logs.add(sb.toString()));
}

  // ------------------- ЛОГИКА ТАЙМЕРА -------------------
  static const int _startSeconds = 60;
  int _secondsLeft = _startSeconds;
  Timer? _timer;

  void _startOrRestartTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _startSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Color _timerColor() {
    if (_secondsLeft == 0) return Colors.red;
    if (_secondsLeft <= 10) return Colors.yellow;
    return Theme.of(context).primaryColor;
  }

  // ---------------- МЕНЮ ИГРОКА (фоллы, переим. и выставление) -------------
  void _showPlayerMenu(Player player) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Переименовать'),
            onTap: () {
              Navigator.pop(context);
              _renamePlayer(player);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('+ фолл'),
            onTap: () {
              Navigator.pop(context);
              setState(() => player.fouls++);
            },
          ),
          ListTile(
            leading: const Icon(Icons.outlined_flag),
            title: const Text('+ тех фолл'),
            onTap: () {
              Navigator.pop(context);
              setState(() => player.techFouls++);
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote),
            title: const Text('+ выставление'),
            onTap: () {
              Navigator.pop(context);
              _addNomination(player.number);
            },
          ),
        ],
      ),
    );
  }

  void _renamePlayer(Player player) {
    final controller = TextEditingController(text: player.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Имя игрока ${player.number}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Новое имя'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) player.name = newName;
              });
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _addNomination(int playerNum) {
    setState(() {
      if (!nominations.contains(playerNum)) {
        nominations.add(playerNum);
        votes[playerNum] = [0, 0, 0]; // инициализируем голоса
      }
    });
  }

  void _changeVote(int playerNum, int round, int delta) {
    setState(() {
      final list = votes[playerNum]!;
      final newVal = (list[round] + delta).clamp(0, 10);
      list[round] = newVal;
    });
  }

  void _showLogs() {
  final all = _logs.join('\n');
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Журнал партии'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: SelectableText(
            all.isEmpty ? 'Пока пусто' : all,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: all.isEmpty
              ? null
              : () {
                  Clipboard.setData(ClipboardData(text: all));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Скопировано в буфер')),
                  );
                },
          child: const Text('Копировать'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    ),
  );
}

  // ----------------------- UI СТРАНИЦ ----------------------
  Widget _buildMainScreen() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // ---- ТАЙМЕР ----
          GestureDetector(
            onTap: _startOrRestartTimer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _timerColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _formatSeconds(_secondsLeft),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ---- СПИСОК ИГРОКОВ ----
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, i) {
                final p = players[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  elevation: 1,
                  child: ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: CircleAvatar(radius: 14, child: Text('${p.number}', style: const TextStyle(fontSize: 12))),
                    title: Text(p.name, style: const TextStyle(fontSize: 14)),
                    subtitle: Row(children: [
                      if (p.fouls > 0) Text('Фоллы: ${p.fouls}   ', style: const TextStyle(fontSize: 12)),
                      if (p.techFouls > 0) Text('Тех: ${p.techFouls}   ', style: const TextStyle(fontSize: 12)),
                      if (nominations.contains(p.number)) const Text('На голосовании', style: TextStyle(fontSize: 12)),
                    ]),
                    onTap: () => _showPlayerMenu(p),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

Widget _buildVotingScreen() {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- ТАБЛИЦА ----
        Expanded(
          child: nominations.isEmpty
              ? const Center(child: Text('Пока никто не выставлен'))
              : ListView(
                  children: [
                    DataTable(
                      columnSpacing: 20,
                      headingRowHeight: 32,
                      dataRowHeight: 36,
                      columns: const [
                        DataColumn(label: Text('№')),
                        DataColumn(label: Text('        1й')),
                        DataColumn(label: Text('        2й')),
                        DataColumn(label: Text('        3й')),
                      ],
                      rows: nominations.map((num) {
                        votes.putIfAbsent(num, () => [0, 0, 0]);
                        final v = votes[num]!;
                        return DataRow(cells: [
                          DataCell(Text('$num')),
                          for (int r = 0; r < 3; r++)
                            DataCell(
                              SizedBox(
                                width: 48,
                                child: TextFormField(
                                  initialValue: v[r].toString(),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    final parsed = int.tryParse(value);
                                    if (parsed != null) {
                                      setState(() => votes[num]![r] = parsed);
                                    }
                                  },
                                ),
                              ),
                            ),
                        ]);
                      }).toList(),
                    ),
                  ],
                ),
        ),

        // ---- КНОПКА СБРОСА ----
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Align(
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Сбросить голосование'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: _resetVoting,
            ),
          ),
        ),

        // ---- ДОП. ПОЛЯ ----
        const SizedBox(height: 12),
        TextFormField(
          controller: _bestMoveCtrl,
          decoration: const InputDecoration(
            labelText: 'Лучший ход',
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _killOrderCtrl,
          decoration: const InputDecoration(
            labelText: 'Порядок отстрелов',
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
        ),
        const SizedBox(height: 12),
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    ElevatedButton.icon(
      icon: const Icon(Icons.save_alt, size: 18),
      label: const Text('Сохранить раунд'),
      onPressed: _saveRoundToLog,
    ),
    OutlinedButton.icon(
      icon: const Icon(Icons.list, size: 18),
      label: const Text('Логи'),
      onPressed: _showLogs,
    ),
  ],
),
      ],
    ),
  );
}

/// Сброс голосования и номинаций
void _resetVoting() {
  setState(() {
    votes.clear();
    nominations.clear();
    // Если храните флаг isNominated у игроков:
    // for (final p in players) p.isNominated = false;
  });
}

  // ------------------------- BUILD ------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ведущий – классическая мафия')),
      body: PageView(
        physics: const ClampingScrollPhysics(), // обычный «жест» без отдачи
        children: [
          _buildMainScreen(),   // влево -> голосование
          _buildVotingScreen(),
        ],
      ),
    );
  }

  String _formatSeconds(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    _bestMoveCtrl.dispose();
    _killOrderCtrl.dispose();
    super.dispose();
  }
}
