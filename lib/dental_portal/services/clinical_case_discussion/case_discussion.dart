import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Post {
  final String id;
  final String user;
  final String userFullName;
  final String text;
  final List<dynamic> images;
  final String createdAt;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.user,
    required this.userFullName,
    required this.text,
    required this.images,
    required this.createdAt,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    var list = json['comments'] as List;
    List<Comment> commentList = list.map((i) => Comment.fromJson(i)).toList();

    return Post(
      id: json['id'] ?? '',
      user: json['user'] ?? '',
      userFullName: json['user_full_name'] ?? '',
      text: json['text'] ?? '',
      images: json['images'] ?? [],
      createdAt: json['created_at'] ?? '',
      comments: commentList,
    );
  }
}

class Comment {
  final String id;
  final String post;
  final String user;
  final String text;
  final String? image;
  final String createdAt;
  final List<Reply> replies;

  Comment({
    required this.id,
    required this.post,
    required this.user,
    required this.text,
    this.image,
    required this.createdAt,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    var list = json['replies'] as List;
    List<Reply> replyList = list.map((i) => Reply.fromJson(i)).toList();

    return Comment(
      id: json['id'] ?? '',
      post: json['post'] ?? '',
      user: json['user'] ?? '',
      text: json['text'] ?? '',
      image: json['image'],
      createdAt: json['created_at'] ?? '',
      replies: replyList,
    );
  }
}

class Reply {
  final String id;
  final String comment;
  final String user;
  final String text;
  final String? image;
  final String createdAt;

  Reply({
    required this.id,
    required this.comment,
    required this.user,
    required this.text,
    this.image,
    required this.createdAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] ?? '',
      comment: json['comment'] ?? '',
      user: json['user'] ?? '',
      text: json['text'] ?? '',
      image: json['image'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ClinicalCaseDiscussion extends StatefulWidget {
  final String accessToken;

  ClinicalCaseDiscussion({required this.accessToken});

  @override
  _ClinicalCaseDiscussionState createState() => _ClinicalCaseDiscussionState();
}

class _ClinicalCaseDiscussionState extends State<ClinicalCaseDiscussion> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/posts/view-and-create-posts/'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {
      futurePosts = fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clinical Case Discussion'),
      ),
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Post>? posts = snapshot.data;
            return RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView.builder(
                itemCount: posts?.length ?? 0,
                itemBuilder: (context, index) {
                  return PostCard(
                      post: posts![index], accessToken: widget.accessToken);
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CreatePostScreen(accessToken: widget.accessToken),
          ),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final String accessToken;

  PostCard({required this.post, required this.accessToken});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitComment() async {
    if (_commentController.text.isNotEmpty) {
      var response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/posts/comments/'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'post': widget.post.id,
          'text': _commentController.text,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          widget.post.comments
              .add(Comment.fromJson(json.decode(response.body)));
        });
        _commentController.clear();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit comment')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.post.text),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post.userFullName),
                Text(widget.post.createdAt),
              ],
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            Column(
              children: [
                Column(
                  children: widget.post.comments.map((comment) {
                    return CommentCard(
                        comment: comment, accessToken: widget.accessToken);
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            labelText: 'Write a comment...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _submitComment,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class CommentCard extends StatefulWidget {
  final Comment comment;
  final String accessToken;

  CommentCard({required this.comment, required this.accessToken});

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.comment.text),
            subtitle: Text(widget.comment.createdAt),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            Column(
              children: widget.comment.replies.map((reply) {
                return ListTile(
                  title: Text(reply.text),
                  subtitle: Text(reply.createdAt),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  final String accessToken;

  CreatePostScreen({required this.accessToken});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/posts/view-and-create-posts/'),
      );
      request.headers['Authorization'] = 'Bearer ${widget.accessToken}';
      request.fields['text'] = _textController.text;

      for (var image in _images) {
        request.files.add(
          await http.MultipartFile.fromPath('files', image.path),
        );
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Post submitted')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit post')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(labelText: 'Post Text'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              Wrap(
                children: _images
                    .map((image) => Image.file(image, width: 100, height: 100))
                    .toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitPost,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
