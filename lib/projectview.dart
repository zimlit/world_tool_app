import 'package:flutter/material.dart';
import 'package:world_tool_app/title_case.dart';
import 'package:world_tool_projects/world_tool_projects.dart';

class ProjectView extends StatelessWidget {
  final Project project;
  final Function(String val) descCallback;

  const ProjectView({
    Key? key,
    required this.project,
    required this.descCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Text(
          project.name.toTitleCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        TextFormField(
          initialValue: project.desc,
          textAlign: TextAlign.center,
          onChanged: descCallback,
          minLines: 1,
          maxLines: null,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ],
    ));
  }
}
