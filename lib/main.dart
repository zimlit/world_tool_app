import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:world_tool_app/projectview.dart';
import 'package:world_tool_projects/world_tool_projects.dart';

void main() {
  runApp(const App());
}

enum _Page { Page, projectView }

enum _FileOptions { newf, open, save }

class Page extends StatefulWidget {
  const Page({Key? key}) : super(key: key);

  @override
  State<Page> createState() => _HomeState();
}

class _HomeState extends State<Page> {
  final _formKey = GlobalKey<FormState>();

  _Page _page = _Page.Page;
  Project? _project;
  String? _path;

  Widget _getWidget() {
    if (_page == _Page.Page) {
      return const Text("hello");
    } else if (_page == _Page.projectView) {
      return ProjectView(
        project: _project!,
        descCallback: (val) {
          setState(() {
            _project!.desc = val;
          });
        },
      );
    } else {
      return const Text("invalid");
    }
  }

  void _newFile() async {
    String? result = await FilePicker.platform.saveFile(
      dialogTitle: 'Please select a file to save the project to',
      fileName: 'name.world',
    );
    if (result == null) {
      return;
    } else {
      var file = File(result);
      var name = p.basenameWithoutExtension(file.path);
      var proj = Project(name, "");
      final controller = TextEditingController();
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Description"),
              content: Form(
                  key: _formKey,
                  child: Container(
                    constraints: BoxConstraints(
                        minHeight: 86,
                        maxHeight: MediaQuery.of(context).size.height),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: controller,
                          minLines: 1,
                          maxLines: null,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              proj.desc = controller.text;
                            }
                            Navigator.of(context).pop();
                          },
                          child: const Text("Done"))
                    ]),
                  )),
            );
          });

      file.writeAsString(proj.toString());
      setState(() {
        _project = proj;
        _path = result;
        _page = _Page.projectView;
      });
    }
  }

  void _saveFile() {
    if (_page != _Page.projectView) {
      return;
    }
    var file = File(_path!);
    file.writeAsString(_project.toString());
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("saved file")));
  }

  void _openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    var path = result.files.single.path!;
    var file = File(path);
    var data = await file.readAsString();
    var proj = Project.fromXml(data);
    setState(() {
      _project = proj;
      _path = path;
      _page = _Page.projectView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 75, 45),
        leading: PopupMenuButton(
          child: const Center(child: Text("file")),
          offset: const Offset(0, 65),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              child: Row(children: const [
                Icon(Icons.add, color: Colors.white),
                Text("New"),
              ]),
              value: _FileOptions.newf,
            ),
            PopupMenuItem(
              child: Row(children: const [
                Icon(Icons.file_open, color: Colors.white),
                Text("Open"),
              ]),
              value: _FileOptions.open,
            ),
            PopupMenuItem(
              child: Row(children: const [
                Icon(Icons.save, color: Colors.white),
                Text("Save"),
              ]),
              value: _FileOptions.save,
            )
          ],
          onSelected: (val) async {
            switch (val) {
              case _FileOptions.open:
                {
                  _openFile();
                  break;
                }
              case _FileOptions.save:
                {
                  _saveFile();
                  break;
                }
              case _FileOptions.newf:
                {
                  _newFile();
                  break;
                }
            }
          },
        ),
      ),
      body: _getWidget(),
    );
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'World Tool',
        theme: ThemeData(
            colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: const Color.fromARGB(255, 35, 75, 45),
          onPrimary: Colors.white,
          secondary: const Color.fromARGB(255, 65, 138, 83),
          onSecondary: Colors.white,
          surface: const Color.fromARGB(255, 42, 46, 42),
          onSurface: Colors.white,
          background: const Color.fromARGB(255, 32, 33, 32),
          onBackground: Colors.white,
          error: Colors.red[800]!,
          onError: Colors.white,
        )),
        home: const Page());
  }
}
