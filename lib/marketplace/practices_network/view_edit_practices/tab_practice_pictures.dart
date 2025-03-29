import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';

class PicturesTab extends StatefulWidget {
  final String practiceId;
  final int numberOfChairs;
  PicturesTab({required this.practiceId, required this.numberOfChairs});

  @override
  _PicturesTabState createState() => _PicturesTabState();
}

class _PicturesTabState extends State<PicturesTab> {
  final picker = ImagePicker();

  late Map<String, String> imageLabels;
  Map<String, dynamic> uploadedImages =
      {}; // {image_type: {"id":..., "url":...}}
  bool isLoading = true;
  Map<String, String> imageDescriptions = {};
  List<String> orderedImageTypes = [];

  @override
  void initState() {
    super.initState();
    generateImageLabels();
    fetchImages();
  }

  void generateImageLabels() {
    imageDescriptions = {
      "front": "Roadside/front elevation of the practice",
      "reception": "Patient greeting area at entry",
      "waiting_area": "Where patients sit before treatment",
    };

    for (int i = 1; i <= widget.numberOfChairs; i++) {
      final key = "surgery$i";
      imageDescriptions[key] = "Chair/operatory $i workspace";
    }

    imageDescriptions.addAll({
      "decontamination": "Sterilization area",
      "staff_room": "Rest/locker area for team",
      "accessibility": "Ramp, door access, etc.",
      "xray_room": "Room where radiographs are taken",
    });

    // Order of fields for UI display
    orderedImageTypes = [
      "front",
      "reception",
      "waiting_area",
      ...List.generate(widget.numberOfChairs, (i) => "surgery${i + 1}"),
      "decontamination",
      "staff_room",
      "accessibility",
      "xray_room",
    ];
  }

  Future<void> fetchImages() async {
    final url = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/practice-images/${widget.practiceId}/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          uploadedImages.clear();
          for (var img in data) {
            uploadedImages[img['image_type']] = {
              "id": img['id'],
              "url": img['image'],
            };
          }
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load images");
      }
    } catch (e) {
      print("❌ Error fetching images: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> uploadImage(String imageType) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // 🔲 Crop the image before upload
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 2.5),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile == null) return;

    final uri = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/upload-practice-image/');
    final request = http.MultipartRequest('POST', uri);
    request.fields['practice'] = widget.practiceId;
    request.fields['image_type'] = imageType;
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      croppedFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ $imageType uploaded')),
      );
      fetchImages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to upload')),
      );
    }
  }

  Future<void> deleteImage(String imageId) async {
    final url = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/practices_setup/delete-practice-image/$imageId/');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🗑️ Image deleted")),
        );
        fetchImages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to delete image")),
        );
      }
    } catch (e) {
      print("❌ Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      children: orderedImageTypes.map((imageType) {
        final label = imageType.contains("surgery")
            ? (widget.numberOfChairs == 1
                ? "Surgery Room"
                : "Surgery Room ${imageType.replaceAll("surgery", "")}")
            : imageType
                .replaceAll("_", " ")
                .split(' ')
                .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
                .join(' ');

        final imageData = uploadedImages[imageType];

        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            title: Row(
              children: [
                Expanded(child: Text(label)),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("$label Description"),
                        content: Text(
                            imageDescriptions[imageType] ?? "No description."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text("Close"),
                          )
                        ],
                      ),
                    );
                  },
                  child: Icon(Icons.help_outline, color: Colors.grey),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageData != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          AspectRatio(
                            aspectRatio: 4 / 2.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "${imageData['url']}?v=${DateTime.now().millisecondsSinceEpoch}",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => deleteImage(imageData['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text("Delete"),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => uploadImage(imageType),
                                child: Text("Replace"),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          "No image uploaded. Please click the Upload button on the right.",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
              ],
            ),
            trailing: imageData == null
                ? ElevatedButton(
                    onPressed: () => uploadImage(imageType),
                    child: Text("Upload"),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
