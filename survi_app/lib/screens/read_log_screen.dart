import 'package:flutter/material.dart';
import 'package:survi_app/services/log_services.dart';

class ReadLogs extends StatelessWidget {
  const ReadLogs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Logs'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () async {
                String logs = await LogService.readLogs();
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: SingleChildScrollView(
                            child: Text(logs),
                          ),
                        ));
              },
              child: const Text('Read Logs')),
        ],
      ),
    );
  }
}
