import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'map_selector.dart'; // Import the renamed map selector

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
    _generateSampleData(); // Generate sample data on init
  }

  void _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemsData = prefs.getString('items');
    if (itemsData != null) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(json.decode(itemsData));
      });
    }
  }

  void _generateSampleData() {
    List<Map<String, dynamic>> sampleItems = [];
    final categories = ['Category 1', 'Category 2', 'Category 3'];
    final random = Random();

    for (int i = 0; i < 50; i++) {
      sampleItems.add({
        'name': 'Item $i',
        'location': '${random.nextDouble() * 180 - 90}, ${random.nextDouble() * 360 - 180}', // Random LatLng
        'category': categories[random.nextInt(categories.length)],
      });
    }

    // Save sample data to SharedPreferences
    _items.addAll(sampleItems);
    _saveItems();
  }

  void _saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('items', json.encode(_items));
  }

  void _addItem(String name, String location, String category) async {
    final newItem = {'name': name, 'location': location, 'category': category};
    setState(() {
      _items.add(newItem);
    });
    _saveItems(); // Save new item to SharedPreferences
  }

  void _openAddItemBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddItemForm(onSubmit: _addItem);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('${item['location']} - ${item['category']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItemBottomSheet,
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddItemForm extends StatefulWidget {
  final Function(String, String, String) onSubmit;

  AddItemForm({required this.onSubmit});

  @override
  _AddItemFormState createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Category 1';
  String _location = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: TextEditingController(text: _location),
            decoration: InputDecoration(
              labelText: 'Location (tap to select)',
            ),
            readOnly: true,
            onTap: () async {
              final selectedLocation = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapSelector()),
              );
              if (selectedLocation != null) {
                setState(() {
                  _location = selectedLocation;
                });
              }
            },
          ),
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
            items: <String>['Category 1', 'Category 2', 'Category 3']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () {
              if (_location.isNotEmpty) {
                widget.onSubmit(
                  _nameController.text,
                  _location,
                  _selectedCategory,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Add Item'),
          ),
        ],
      ),
    );
  }
}
