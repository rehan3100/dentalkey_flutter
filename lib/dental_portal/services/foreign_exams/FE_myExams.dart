import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dental_key/dental_portal/services/foreign_exams/FE_quiz_page.dart';

class MyForeignExams extends StatefulWidget {
  final String accessToken;
  final String email;

  const MyForeignExams({
    Key? key,
    required this.accessToken,
    required this.email,
  }) : super(key: key);

  @override
  _MyForeignExamsState createState() =>
      _MyForeignExamsState(accessToken: accessToken);
}

class _MyForeignExamsState extends State<MyForeignExams> {
  bool isLoading = true;
  final String accessToken;
  List<Quiz> quizzes = [];

  _MyForeignExamsState({required this.accessToken});

  Future<void> _fetchQuizzes() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/requested-quizzes/postgraduate/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (mounted) {
          setState(() {
            quizzes = responseData.map((data) => Quiz.fromJson(data)).toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch quizzes');
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

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> refreshpage() async {
    await _fetchQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Licensing Mock Exams'),
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
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : quizzes.isEmpty
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
                    : ListView.builder(
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizzes[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(quiz.coverImage),
                            ),
                            title: Text(quiz.quizName),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizPage(
                                      quizId: quiz.quizId,
                                      accessToken: accessToken,
                                      title: quiz.quizName,
                                      description: quiz.description,
                                      quizImage: quiz.coverImage,
                                      timer_seconds: quiz.timer_seconds,
                                      red_timer: quiz.red_timer,
                                      flashing_timer: quiz.flashing_timer,
                                      allowedAttempts: quiz.allowedAttempts,
                                      remainingAttempt: quiz.remainingAttempt,
                                      displayAllQuestionsOnOnePage:
                                          quiz.displayAllQuestionsOnOnePage,
                                      total_questions: quiz.total_questions,
                                      show_questions_counter:
                                          quiz.show_questions_counter,
                                      enable_navigation_bar:
                                          quiz.enable_navigation_bar,
                                      enable_live_progress_bar:
                                          quiz.enable_live_progress_bar,
                                      show_questions_category:
                                          quiz.show_questions_category,
                                      enable_timer: quiz.enable_timer,
                                      published_status: quiz.published_status,
                                      schedule_quiz: quiz.schedule_quiz,
                                      message_if_unpublished:
                                          quiz.message_if_unpublished,
                                      start_date: quiz.start_date,
                                      end_date: quiz.end_date,
                                      show_start_date_on_my_quiz:
                                          quiz.show_start_date_on_my_quiz,
                                      show_end_date_on_my_quiz:
                                          quiz.show_end_date_on_my_quiz,
                                      show_start_date_counter_on_my_quiz: quiz
                                          .show_start_date_counter_on_my_quiz,
                                      show_end_date_counter_on_my_quiz:
                                          quiz.show_end_date_counter_on_my_quiz,
                                      display_pass_fail_status:
                                          quiz.display_pass_fail_status,
                                      display_score_table:
                                          quiz.display_score_table,
                                      display_percentage_marks:
                                          quiz.display_percentage_marks,
                                      display_correct_answers_on_result_page: quiz
                                          .display_correct_answers_on_result_page,
                                      display_unattempted_answers_on_result_page:
                                          quiz.display_unattempted_answers_on_result_page,
                                      display_wrong_answers_on_result_page: quiz
                                          .display_wrong_answers_on_result_page,
                                      show_question_explanation_with_result: quiz
                                          .show_question_explanation_with_result,
                                      email: widget.email,
                                    ),
                                  ),
                                );
                              },
                              child: Text('Attempt Quiz'),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
