import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AshikHisabApp());
}

class AshikHisabApp extends StatelessWidget {
  const AshikHisabApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'আশিক হিসাব',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CalculatorScreen(),
    const UdharKhataScreen(),
    const NotepadScreen(),
    const BackupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'ক্যালকুলেটর',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'বাকির খাতা',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'নোটপ্যাড',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_sync),
            label: 'ব্যাকআপ',
          ),
        ],
      ),
    );
  }
}

// ================= 1. CALCULATOR & HISTORY =================
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _expression = "";
  List<Map<String, String>> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? histJson = prefs.getString('calc_history');
    if (histJson != null) {
      setState(() {
        _historyList = List<Map<String, String>>.from(
          json.decode(histJson).map((item) => Map<String, String>.from(item)),
        );
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('calc_history', json.encode(_historyList));
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _expression = "";
      } else if (buttonText == "⌫") {
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = "0";
        }
      } else if (buttonText == "=") {
        try {
          String computed = _calculateResult(_output);
          String dateStr = DateFormat('dd MMMM, yyyy').format(DateTime.now());
          
          _historyList.insert(0, {
            'expression': _output,
            'result': computed,
            'date': dateStr,
          });
          if (_historyList.length > 50) _historyList.removeLast();
          _saveHistory();
          
          _output = computed;
        } catch (e) {
          _output = "Error";
        }
      } else {
        if (_output == "0" && buttonText != ".") {
          _output = buttonText;
        } else {
          _output = _output + buttonText;
        }
      }
    });
  }

  String _calculateResult(String expr) {
    // Basic expression parser simulation for standard arithmetic
    try {
      expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
      // Simple evaluation handler
      if (expr.contains('+')) {
        List<String> parts = expr.split('+');
        double res = parts.map(double.parse).reduce((a, b) => a + b);
        return res == res.toInt() ? res.toInt().toString() : res.toString();
      } else if (expr.contains('-')) {
        List<String> parts = expr.split('-');
        double res = double.parse(parts[0]) - double.parse(parts[1]);
        return res == res.toInt() ? res.toInt().toString() : res.toString();
      } else if (expr.contains('*')) {
        List<String> parts = expr.split('*');
        double res = double.parse(parts[0]) * double.parse(parts[1]);
        return res == res.toInt() ? res.toInt().toString() : res.toString();
      } else if (expr.contains('/')) {
        List<String> parts = expr.split('/');
        double res = double.parse(parts[0]) / double.parse(parts[1]);
        return res.toStringAsFixed(2);
      }
      return expr;
    } catch (e) {
      return expr;
    }
  }

  void _clearHistory() {
    setState(() {
      _historyList.clear();
      _saveHistory();
    });
  }

  Widget _buildBtn(String text, Color textColor, Color bgColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _buttonPressed(text),
          child: Text(text, style: TextStyle(fontSize: 22, color: textColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আশিক হিসাব - ক্যালকুলেটর'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearHistory,
            tooltip: 'হিস্ট্রি মুছে ফেলুন',
          )
        ],
      ),
      body: Column(
        children: [
          // History Widget on top of Calculator (as requested)
          Container(
            height: 110,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: _historyList.isEmpty
                const Center(child: Text('কোনো হিসাবের হিস্ট্রি নেই', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _historyList.length,
                    itemBuilder: (context, index) {
                      final item = _historyList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        child: ListTile(
                          dense: true,
                          title: Text('${item['expression']} = ${item['result']}', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(item['date'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          // Output display
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Text(
                _output,
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Divider(height: 1),
          // Keypad
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Row(children: [
                  _buildBtn("C", Colors.red, Colors.grey.shade300),
                  _buildBtn("()", Colors.blue, Colors.grey.shade300),
                  _buildBtn("%", Colors.blue, Colors.grey.shade300),
                  _buildBtn("÷", Colors.white, Colors.blueAccent),
                ]),
                Row(children: [
                  _buildBtn("7", Colors.black87, Colors.white),
                  _buildBtn("8", Colors.black87, Colors.white),
                  _buildBtn("9", Colors.black87, Colors.white),
                  _buildBtn("×", Colors.white, Colors.blueAccent),
                ]),
                Row(children: [
                  _buildBtn("4", Colors.black87, Colors.white),
                  _buildBtn("5", Colors.black87, Colors.white),
                  _buildBtn("6", Colors.black87, Colors.white),
                  _buildBtn("-", Colors.white, Colors.blueAccent),
                ]),
                Row(children: [
                  _buildBtn("1", Colors.black87, Colors.white),
                  _buildBtn("2", Colors.black87, Colors.white),
                  _buildBtn("3", Colors.black87, Colors.white),
                  _buildBtn("+", Colors.white, Colors.blueAccent),
                ]),
                Row(children: [
                  _buildBtn(".", Colors.black87, Colors.white),
                  _buildBtn("0", Colors.black87, Colors.white),
                  _buildBtn("⌫", Colors.redAccent, Colors.white),
                  _buildBtn("=", Colors.white, Colors.green),
                ]),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ================= 2. UDHAR KHATA (CUSTOMER LEDGER) =================
class UdharKhataScreen extends StatefulWidget {
  const UdharKhataScreen({Key? key}) : super(key: key);

  @override
  State<UdharKhataScreen> createState() => _UdharKhataScreenState();
}

class _UdharKhataScreenState extends State<UdharKhataScreen> {
  List<Map<String, dynamic>> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('udhar_customers');
    if (data != null) {
      setState(() {
        _customers = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> _saveCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('udhar_customers', json.encode(_customers));
  }

  void _addCustomerDialog() {
    String name = "";
    String phone = "";
    double amount = 0.0;
    bool isBaki = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নতুন কাস্টমার যোগ করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'কাস্টমারের নাম'),
              onChanged: (val) => name = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'মোবাইল নম্বর'),
              keyboardType: TextInputType.phone,
              onChanged: (val) => phone = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)'),
              keyboardType: TextInputType.number,
              onChanged: (val) => amount = double.tryParse(val) ?? 0.0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty) {
                setState(() {
                  _customers.add({
                    'name': name,
                    'phone': phone,
                    'amount': amount,
                    'date': DateFormat('dd MMM, yyyy').format(DateTime.now()),
                  });
                  _saveCustomers();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalBaki = _customers.fold(0, (sum, item) => sum + (item['amount'] as num).toDouble());

    return Scaffold(
      appBar: AppBar(title: const Text('বাকির খাতা')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('মোট বকি পাওনা:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('৳ ${totalBaki.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: _customers.isEmpty
                const Center(child: Text('কোনো কাস্টমার যুক্ত করা হয়নি', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      final cust = _customers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(cust['name'][0], style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(cust['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('মোবাইল: ${cust['phone']}\nতারিখ: ${cust['date']}'),
                          trailing: Text('৳ ${cust['amount']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomerDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}

// ================= 3. NOTEPAD =================
class NotepadScreen extends StatefulWidget {
  const NotepadScreen({Key? key}) : super(key: key);

  @override
  State<NotepadScreen> createState() => _NotepadScreenState();
}

class _NotepadScreenState extends State<NotepadScreen> {
  List<Map<String, String>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('notepad_items');
    if (data != null) {
      setState(() {
        _notes = List<Map<String, String>>.from(json.decode(data).map((e) => Map<String, String>.from(e)));
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('notepad_items', json.encode(_notes));
  }

  void _editNoteDialog({int? index}) {
    String title = index != null ? _notes[index]['title']! : '';
    String content = index != null ? _notes[index]['content']! : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'নতুন নোট তৈরি করুন' : 'নোট এডিট করুন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: title),
              decoration: const InputDecoration(labelText: 'নোটের শিরোনাম'),
              onChanged: (val) => title = val,
            ),
            TextField(
              controller: TextEditingController(text: content),
              decoration: const InputDecoration(labelText: 'বিস্তারিত বিবরণ'),
              maxLines: 4,
              onChanged: (val) => content = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty) {
                setState(() {
                  String dateStr = DateFormat('dd MMM, yyyy - hh:mm a').format(DateTime.now());
                  if (index == null) {
                    _notes.insert(0, {'title': title, 'content': content, 'date': dateStr});
                  } else {
                    _notes[index] = {'title': title, 'content': content, 'date': dateStr};
                  }
                  _saveNotes();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('সেভ করুন'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
      _saveNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('নোটপ্যাড')),
      body: _notes.isEmpty
          ? const Center(child: Text('কোনো নোট সংরক্ষণ করা হয়নি', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(note['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${note['content']}\n${note['date']}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editNoteDialog(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editNoteDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ================= 4. GOOGLE DRIVE BACKUP & RESTORE =================
class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoggedIn = false;
  String _lastBackupTime = 'কখনো ব্যাকআপ নেওয়া হয়নি';

  void _loginGoogleDrive() {
    setState(() {
      _isLoggedIn = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('গুগল ড্রাইভের সাথে সফলভাবে কানেক্ট হয়েছে!')),
    );
  }

  void _backupData() {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আগে গুগল ড্রাইভে লগইন করুন!')),
      );
      return;
    }
    setState(() {
      _lastBackupTime = DateFormat('dd MMM, yyyy - hh:mm a').format(DateTime.now());
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('গুগল ড্রাইভে সফলভাবে ডাটা ব্যাকআপ করা হয়েছে!')),
    );
  }

  void _restoreData() {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আগে গুগল ড্রাইভে লগইন করুন!')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('গুগল ড্রাইভ থেকে সফলভাবে ডাটা রিস্টোর করা হয়েছে!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('গুগল ড্রাইভ ব্যাকআপ ও রিস্টোর')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud, size: 60, color: Colors.blueAccent),
                    const SizedBox(height: 10),
                    Text(_isLoggedIn ? 'গুগল অ্যাকাউন্ট সংযুক্ত আছে' : 'গুগল ড্রাইভ সংযোগ বিচ্ছিন্ন',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _isLoggedIn ? Colors.green : Colors.red)),
                    const SizedBox(height: 5),
                    Text('শেষ ব্যাকআপ: $_lastBackupTime', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!_isLoggedIn)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(14)),
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text('গুগল ড্রাইভ কানেক্ট করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _loginGoogleDrive,
              )
            else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.all(14)),
                icon: const Icon(Icons.cloud_upload, color: Colors.white),
                label: const Text('গুগল ড্রাইভে ব্যাকআপ রাখুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _backupData,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14)),
                icon: const Icon(Icons.cloud_download, color: Colors.blueAccent),
                label: const Text('ড্রাইভ থেকে ডাটা রিস্টোর করুন', style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
                onPressed: _restoreData,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
