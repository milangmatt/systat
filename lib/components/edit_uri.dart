import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class EditUriDialog extends StatefulWidget {
  final Function(String) onConfirm;
  const EditUriDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<EditUriDialog> createState() => _EditUriDialogState();
}

class _EditUriDialogState extends State<EditUriDialog> {
  final TextEditingController UriIn = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit API endpoint url',
            style: TextStyle(fontSize: 20.sp),
          ),
          SizedBox(
            height: 20.h,
          ),
          TextField(
            controller: UriIn,
            decoration: InputDecoration(
              labelText: 'Enter API endpoint url',
              border: UnderlineInputBorder(),
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Theme.of(context).colorScheme.onPrimary,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  String url = UriIn.text;
                  try {
                    var client = http.Client();
                    var uri = Uri.parse(url);
                    var response = await client.get(uri);
                    widget.onConfirm(url);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid API endpoint url')));
                  }
                },
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Theme.of(context).colorScheme.onSurface,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
