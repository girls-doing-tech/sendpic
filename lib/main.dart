
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

void main() async{
  // ensure all widgets successfully initialized
  WidgetsFlutterBinding.ensureInitialized();
  // initialize fire base
  Platform.isAndroid ?
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDy2NMkDCnD2c8c0kXVWjZJL5SMTJ86W8M",
        appId: "1:1046899290518:android:d8b6583bcd3915c3452db7",
        messagingSenderId: "1046899290518",
        projectId: "sendwallet-c3509",
        storageBucket: "gs://sendwallet-c3509.appspot.com",
      )) : await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  pickProfileImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    } else {
      return 'No Image Selected';
    }
  }
  Future<Uint8List?> compressImage(Uint8List image) async {
    // Compress the image using flutter_image_compress
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      image,
      minHeight: 1920, // set the minimum height
      minWidth: 1080,  // set the minimum width
      quality: 80,     // set the quality percentage
    );

    // Return the compressed image as Uint8List
    return Uint8List.fromList(compressedBytes);
  }
  _uploadImageToStorage(Uint8List? image,String name) async {
    // create folder profile image and the name of image to be user uid
    Uint8List? compressedImage = await compressImage(image!);

    Reference ref = await _storage
        .ref()
        .child('profileImage')
        .child(name);
    // put data into upload
    final newMetadata = SettableMetadata(
      contentType: "image",
    );

    UploadTask uploadTask = ref.putData(image!, newMetadata);
    // wait data to be fully uploaded and save upload data into snapshot
    TaskSnapshot snapshot = await uploadTask;
    // get uploaded image url from the storage
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  Uint8List? image;
   late String imagePath='';
  capturedImage() async {
    Uint8List? img = await pickProfileImage(ImageSource.camera);
    setState(() {
      image = img;
    });
  }
  selectGalleryImage() async {
    Uint8List? img = await pickProfileImage(ImageSource.gallery);
    setState(() {
      image = img;
    });
  }
  /*Future<XFile?> compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    if (lastIndex == filePath.lastIndexOf(RegExp(r'.png'))) {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
          filePath, outPath,
          minWidth: 1000,
          minHeight: 1000,
          quality: 50,
          format: CompressFormat.png);
      return compressedImage;
    } else {
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        minWidth: 1000,
        minHeight: 1000,
        quality: 50,
      );
      return compressedImage;
    }
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Image Picker Example"),
        ),
        body: Center(
          child: Column(
            children: [
              MaterialButton(
                  color: Colors.blue,
                  child: const Text(
                      "Pick Image from Gallery",
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold
                      )
                  ),
                  onPressed: () async{

                    await selectGalleryImage();
                    setState(()async {
                      if(image != null){
                        imagePath=  await _uploadImageToStorage(image!,'12354');
                        print(imagePath);
                      }

                    });

                  }
              ),
              MaterialButton(
                  color: Colors.blue,
                  child: const Text(
                      "Pick Image from Camera",
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold
                      )
                  ),
                  onPressed: ()async  {
                    await capturedImage();
                    setState(()async {
                      if(image != null){
                        print('imagePath');
                        imagePath =  await _uploadImageToStorage(image!,'12354');
                        print(imagePath);
                      }

                    });

                  }
              ),
              image == null
                  ? Text('No image selected.')
                  : CircleAvatar(
                radius: 65,
                backgroundColor: Colors.white,
                backgroundImage: MemoryImage(image!),
              ),
               Text(
               imagePath!
              ),
              imagePath == null
                  ? Text('No image uploaded.')
                  : Image.network(imagePath!),
            ],
          ),
        )
    );
  }
}
