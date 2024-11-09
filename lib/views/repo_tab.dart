import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RepoTab extends StatefulWidget {
  @override
  _RepoTabState createState() => _RepoTabState();
}

class _RepoTabState extends State<RepoTab> {
  List<dynamic> repos = [];

  @override
  void initState() {
    super.initState();
    fetchRepos();
  }

  Future<void> fetchRepos() async {
    final response = await http.get(Uri.parse('https://api.github.com/gists/public'));
    if (response.statusCode == 200) {
      setState(() {
        repos = json.decode(response.body);
      });
    }
  }

  Future<List<dynamic>> fetchFiles(String repoUrl) async {
    final response = await http.get(Uri.parse(repoUrl));
    if (response.statusCode == 200) {
      var repoData = json.decode(response.body);
      return repoData['files'].values.toList();
    } else {
      throw Exception('Failed to load files');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: repos.length,
      itemBuilder: (context,index) {
        final repo = repos[index];
        return ListTile(
          title: Text(repo['description'] ?? 'No Description'),
          subtitle: Row(
            children: [
              Text('Created: ${repo['created_at'].toString().substring(0,10)}'),
              const SizedBox(width: 35),
              const Icon(Icons.update, size: 16),
              const SizedBox(width: 4),
              Text('Today ${repo['updated_at'].toString().substring(11,16)}' ?? 'N/A'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.comment_outlined),
              const SizedBox(width: 4),
              Text(repo['comments'].toString() ?? '0'),
            ],
          ),
          shape: ContinuousRectangleBorder(
            side: const BorderSide(width: 1),
            borderRadius: BorderRadius.circular(0),
          ),
          onTap: () async {
            final files = await fetchFiles(repo['url']);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FilesScreen(files: files),
              ),
            );
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title:const Text('Repo Owner Info'),
                content:Text('${repo['owner']['login']}',
                  style:const TextStyle(fontWeight:FontWeight.bold,fontSize:25,color:Colors.blueAccent),
                ),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
              ),
            );
          },
        );
      },
    );
  }
}

class FilesScreen extends StatelessWidget {
  final List<dynamic> files;

  const FilesScreen({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Files')),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return ListTile(
            title: Text(file['filename'] ?? 'No Filename'),
            subtitle: Text(file['raw_url'] ?? 'No URL'),
            onTap: () {
            },
          );
        },
      ),
    );
  }
}
