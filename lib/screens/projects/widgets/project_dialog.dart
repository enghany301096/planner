import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import '../../../models/project.dart';
import '../../../providers/project_provider.dart';

class ProjectDialog {
  static void show(BuildContext context, {Project? project}) {
    final nameController = TextEditingController(text: project?.name ?? '');
    final descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    DateTime? endDate = project?.endDate;
    String? imagePath = project?.imagePath;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            project == null ? 'addProject'.tr() : 'editProject'.tr(),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.pop(context),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('save'.tr()),
            onPressed: () {
              if (nameController.text.isEmpty) return;

              final newProject = Project(
                id: project?.id ?? const Uuid().v4(),
                name: nameController.text,
                description: descriptionController.text,
                endDate: endDate,
                status: project?.status ?? 'active',
                imagePath: imagePath,
              );

              final provider = Provider.of<ProjectProvider>(
                context,
                listen: false,
              );
              if (project == null) {
                provider.addProject(newProject);
              } else {
                provider.updateProject(newProject);
              }
              Navigator.pop(context);
            },
          ),
        ),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Image Picker
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        imagePath = pickedFile.path;
                      });
                    }
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: CupertinoColors.systemGrey4),
                    ),
                    child: imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.image,
                                size: 50,
                                color: CupertinoColors.systemGrey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'tapToAddImage'.tr(),
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: nameController,
                  placeholder: 'projectName'.tr(),
                  padding: const EdgeInsets.all(12),
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: descriptionController,
                  placeholder: 'description'.tr(),
                  padding: const EdgeInsets.all(12),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
