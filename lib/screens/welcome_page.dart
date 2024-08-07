import 'package:flutter/material.dart';
import '../models/item.dart' as model;
import '../helpers/item.dart' as helper;
import 'login_page.dart'; // Assurez-vous d'importer votre page de connexion

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late Future<List<model.Item>> _items;
  Set<int> _favoriteItemIds = Set<int>();

  @override
  void initState() {
    super.initState();
    _refreshItems();
    _loadFavorites();
  }

  void _refreshItems() {
    setState(() {
      _items = helper.ItemDatabaseHelper().getItems();
    });
  }

  void _showForm(int? id) async {
    final titleController = TextEditingController();
    final typeController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    if (id != null) {
      final item = await helper.ItemDatabaseHelper().getItem(id);
      if (item != null) {
        titleController.text = item.title;
        typeController.text = item.type;
        descriptionController.text = item.description;
        priceController.text = item.price.toString();
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Ajouter un élément' : 'Mettre à jour l\'élément'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Titre'),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text;
              final type = typeController.text;
              final description = descriptionController.text;
              final price = int.tryParse(priceController.text) ?? 0;

              if (title.isEmpty || type.isEmpty || description.isEmpty) {
                return;
              }

              if (id == null) {
                await helper.ItemDatabaseHelper().insertItem(model.Item(
                  title: title,
                  type: type,
                  description: description,
                  price: price,
                ));
              } else {
                await helper.ItemDatabaseHelper().updateItem(model.Item(
                  id: id,
                  title: title,
                  type: type,
                  description: description,
                  price: price,
                ));
              }

              _refreshItems();
              Navigator.of(context).pop();
            },
            child: Text(id == null ? 'Ajouter' : 'Mettre à jour'),
          ),
        ],
      ),
    );
  }

  void _showDetails(model.Item item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetailPage(item: item),
    ));
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  void _toggleFavorite(int itemId) {
    setState(() {
      if (_favoriteItemIds.contains(itemId)) {
        _favoriteItemIds.remove(itemId);
      } else {
        _favoriteItemIds.add(itemId);
      }
    });
    // You might want to persist the favorite state in the database or local storage here
  }

  void _loadFavorites() async {
    // Load the list of favorite item IDs from the database or local storage
    // For now, this is a placeholder
    setState(() {
      _favoriteItemIds = Set<int>(); // Replace with actual data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Product Navigation'),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FavoritesPage(favoriteItemIds: _favoriteItemIds)),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<model.Item>>(
        future: _items,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              final isFavorite = _favoriteItemIds.contains(item.id);

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  onTap: () => _showDetails(item),
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: _getColorForType(item.type),
                    child: Center(
                      child: Text(
                        item.type,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  title: Text(item.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.description),
                      Text('Prix: ${item.price}'),
                      Row(
                        children: List.generate(5, (index) => Icon(Icons.star_border, color: Colors.amber)),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                        color: isFavorite ? Colors.red : null,
                        onPressed: () => _toggleFavorite(item.id!),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showForm(item.id),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await helper.ItemDatabaseHelper().deleteItem(item.id!);
                          _refreshItems();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: Icon(Icons.add),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pixel':
        return Colors.blue;
      case 'laptop':
        return Colors.green;
      case 'tablet':
        return Colors.orange;
      case 'pendrive':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}

class DetailPage extends StatefulWidget {
  final model.Item item;

  DetailPage({required this.item});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    // Initialiser les commentaires si nécessaire
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Card(
                color: Colors.blueAccent,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    widget.item.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Type: ${widget.item.type}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Description: ${widget.item.description}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Prix: ${widget.item.price}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Ajouter un commentaire',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _comments.add(_commentController.text);
                  _commentController.clear();
                });
              },
              child: Text('Ajouter Commentaire'),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_comments[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  final Set<int> favoriteItemIds;

  FavoritesPage({required this.favoriteItemIds});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<model.Item>> _favoriteItems;

  @override
  void initState() {
    super.initState();
    _favoriteItems = _loadFavoriteItems();
  }

  Future<List<model.Item>> _loadFavoriteItems() async {
    final List<model.Item> items = [];
    for (int id in widget.favoriteItemIds) {
      final item = await helper.ItemDatabaseHelper().getItem(id);
      if (item != null) {
        items.add(item);
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Favoris'),
      ),
      body: FutureBuilder<List<model.Item>>(
        future: _favoriteItems,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun élément favori trouvé.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: _getColorForType(item.type),
                    child: Center(
                      child: Text(
                        item.type,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  title: Text(item.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(item.description),
                  trailing: Text('Prix: ${item.price}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pixel':
        return Colors.blue;
      case 'laptop':
        return Colors.green;
      case 'tablet':
        return Colors.orange;
      case 'pendrive':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}