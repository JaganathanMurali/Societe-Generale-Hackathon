import 'package:flutter/material.dart';
import 'package:hello_world/contract_linking.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  ThemeData _buildAppTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContractLinking(),
      child: MaterialApp(
          title: 'Hello World Dapp',
          theme: _buildAppTheme(),
          home: const HelloWorld()),
    );
  }
}

class HelloWorld extends StatefulWidget {
  const HelloWorld({Key? key}) : super(key: key);

  @override
  State<HelloWorld> createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld> {
  TextEditingController yourNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  List<Map<String, String>> submittedData = [];

  @override
  Widget build(BuildContext context) {
    // Getting the value and object or contract_linking
    var contractLink = Provider.of<ContractLinking>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello World !"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: contractLink.isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Hello ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 52),
                            ),
                            Text(
                              contractLink.deployedName ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 52,
                                  color: Color.fromARGB(255, 25, 105, 87)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 29),
                          child: TextFormField(
                            controller: yourNameController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Your Name",
                                hintText: "What is your name?",
                                icon: Icon(Icons.drive_file_rename_outline)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 29),
                          child: TextFormField(
                            controller: mobileNumberController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Mobile Number",
                                hintText: "What is your mobile number?",
                                icon: Icon(Icons.phone)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: ElevatedButton(
                            child: const Text(
                              'Submit',
                              style:
                                  TextStyle(fontSize: 30, color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 27, 92, 122),
                            ),
                            onPressed: () async {
                              String name = yourNameController.text;
                              String mobile = mobileNumberController.text;

                              if (name.isNotEmpty && mobile.isNotEmpty) {
                                await contractLink.setName(name, mobile);
                                setState(() {
                                  submittedData.add({
                                    'name': name,
                                    'mobile': mobile,
                                  });
                                });
                                yourNameController.clear();
                                mobileNumberController.clear();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (submittedData.isNotEmpty)
                          Column(
                            children: [
                              const Text(
                                'Submitted Data:',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: submittedData.length,
                                itemBuilder: (context, index) {
                                  final data = submittedData[index];
                                  return ListTile(
                                    title: Text('Name: ${data['name']}'),
                                    subtitle: Text('Mobile: ${data['mobile']}'),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
