import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dental_key/utils/PdfViewerPage.dart';
import 'package:path_provider/path_provider.dart';

class MyIPS extends StatefulWidget {
  final String accessToken;
  const MyIPS({Key? key, required this.accessToken}) : super(key: key);

  @override
  _MyIPSState createState() => _MyIPSState(accessToken: accessToken);
}

class _MyIPSState extends State<MyIPS> {
  bool isLoading = false;
  final String accessToken;
  List<Book> books = [];
  List<Book> filteredBooks = [];
  String searchQuery = '';
  int? loadingIndex;

  _MyIPSState({required this.accessToken});

  Future<void> _fetchBooks() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/ips/order-books/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            books = responseData.map((data) => Book.fromJson(data)).toList();
            filteredBooks = books;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch books');
      }
    } catch (error) {
      print('Error: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _searchBooks(String query) {
    final filtered = books.where((book) {
      final titleLower = book.book_name.toLowerCase();
      final descriptionLower = book.description.toLowerCase();
      final searchLower = query.toLowerCase();

      return titleLower.contains(searchLower) ||
          descriptionLower.contains(searchLower);
    }).toList();

    if (mounted) {
      setState(() {
        searchQuery = query;
        filteredBooks = filtered;
      });
    }
  }

  Future<void> _loadPdfAsync(
      String pdfUrl, String book_id, String accessToken, int index) async {
    try {
      if (mounted) {
        setState(() {
          loadingIndex = index;
        });
      }

      if (pdfUrl.isEmpty) {
        print('PDF URL is empty.');
        return;
      }

      final watermarkedPdfResponse = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/ips/get_watermarked_pdf/$book_id/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
        },
      );

      if (watermarkedPdfResponse.statusCode == 200) {
        // Save the watermarked PDF locally
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String localFilePath =
            '${appDocDir.path}/watermarked_pdf_$book_id.pdf';
        final File localFile = File(localFilePath);
        await localFile.writeAsBytes(watermarkedPdfResponse.bodyBytes);

        // Open the watermarked PDF using PdfViewerPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(
              pdfPath: localFilePath,
              accessToken: accessToken,
            ),
          ),
        );
      } else {
        throw Exception('Failed to fetch watermarked PDF');
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      if (mounted) {
        setState(() {
          loadingIndex = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> refreshpage() async {
    await _fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My IPS Books'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshpage,
        child: Stack(
          children: [
            // Background Image Container
            Center(
              child: Opacity(
                opacity:
                    0.1, // Adjust the opacity to make the background very transparent
                child: Image.asset(
                  'assets/images/mystore_back.png',
                  width: 300.0, // Set your desired width
                  height: 400.0, // Set your desired height
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Books...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: _searchBooks,
                  ),
                ),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : books.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'Sorry, you didn\'t buy anything yet from this category.',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = filteredBooks[index];
                                return Card(
                                  elevation: 4,
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 200,
                                            width: double.infinity,
                                            child: book.cover_image.isNotEmpty
                                                ? Image.network(
                                                    book.cover_image
                                                            .startsWith('http')
                                                        ? book.cover_image
                                                        : 'https://dental-key-738b90a4d87a.herokuapp.com${book.cover_image}',
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    color: Colors.grey,
                                                  ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.all(8.0),
                                              color: Colors.black54,
                                              child: Text(
                                                book.book_name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          book.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: book.ebook_file != null
                                            ? () => _loadPdfAsync(
                                                  book.ebook_file,
                                                  book.book_id,
                                                  accessToken,
                                                  index,
                                                )
                                            : null,
                                        icon: loadingIndex == index
                                            ? SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Icon(Icons.visibility),
                                        label: loadingIndex == index
                                            ? Text('Loading...')
                                            : Text('Open E-Book'),
                                        style: ButtonStyle(
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  Size(double.infinity, 40)),
                                          backgroundColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.pressed)) {
                                                return Color(0xFF385A92);
                                              }
                                              return Color(0xFF385A92);
                                            },
                                          ),
                                          foregroundColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.pressed)) {
                                                return Colors.white;
                                              }
                                              return Colors.white;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Book {
  final String book_id;
  final String book_name;
  final String description;
  final String price;
  final String cover_image;
  final String glimpse_file;
  final String ebook_file;

  Book({
    required this.book_id,
    required this.book_name,
    required this.description,
    required this.price,
    required this.cover_image,
    required this.glimpse_file,
    required this.ebook_file,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      book_id: json['book_id'],
      book_name: json['book_name'],
      description: json['description'],
      price: json['price'],
      cover_image: json['cover_image'],
      glimpse_file: json['glimpse_file'],
      ebook_file: json['ebook_file'],
    );
  }
}
