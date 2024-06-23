import 'dart:async'; // Add this import
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/07_UG_all_questions_on_single.dart';
import 'package:dental_key/dental_portal/services/ug_exams_tests/07_UG_one_q_per_page_set.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class UGQuiz {
  final String quizId;
  final String quizName;
  final String description;
  final String price;
  final String coverImage;
  final int allowedAttempts;
  final int remainingAttempt;
  final bool displayAllQuestionsOnOnePage; // Add this attribute
  final int total_questions;
  final bool show_questions_counter;
  final bool enable_navigation_bar;
  final bool enable_live_progress_bar;
  final bool show_questions_category;
  final bool enable_timer;
  final int timer_seconds;
  final int flashing_timer;
  final int red_timer;
  final published_status;
  final schedule_quiz;
  final message_if_unpublished;
  final DateTime? start_date;
  final DateTime? end_date;
  final bool show_start_date_on_my_quiz;
  final bool show_end_date_on_my_quiz;
  final bool show_start_date_counter_on_my_quiz;
  final bool show_end_date_counter_on_my_quiz;
  final bool display_pass_fail_status;
  final bool display_score_table;
  final bool display_percentage_marks;
  final bool display_correct_answers_on_result_page;
  final bool display_unattempted_answers_on_result_page;
  final bool display_wrong_answers_on_result_page;
  final bool show_question_explanation_with_result;

  UGQuiz({
    required this.quizId,
    required this.quizName,
    required this.description,
    required this.price,
    required this.coverImage,
    required this.allowedAttempts,
    required this.remainingAttempt,
    required this.displayAllQuestionsOnOnePage, // Initialize it
    required this.total_questions,
    required this.show_questions_counter,
    required this.enable_navigation_bar,
    required this.enable_live_progress_bar,
    required this.show_questions_category,
    required this.enable_timer,
    required this.timer_seconds,
    required this.flashing_timer,
    required this.red_timer,
    required this.published_status,
    required this.schedule_quiz,
    required this.message_if_unpublished,
    required this.start_date,
    required this.end_date,
    required this.show_start_date_on_my_quiz,
    required this.show_end_date_on_my_quiz,
    required this.show_start_date_counter_on_my_quiz,
    required this.show_end_date_counter_on_my_quiz,
    required this.display_pass_fail_status,
    required this.display_score_table,
    required this.display_percentage_marks,
    required this.display_correct_answers_on_result_page,
    required this.display_unattempted_answers_on_result_page,
    required this.display_wrong_answers_on_result_page,
    required this.show_question_explanation_with_result,
  });

  factory UGQuiz.fromJson(Map<String, dynamic> json) {
    return UGQuiz(
      quizId: json['uid'],
      quizName: json['title'],
      description: json['description'],
      price: json['price'],
      coverImage: json['quiz_image'].startsWith('http')
          ? json['quiz_image']
          : 'https://dental-key-738b90a4d87a.herokuapp.com' +
              json['quiz_image'],
      allowedAttempts: json['allowed_attempts'], // No need for null check
      remainingAttempt: json['remaining_attempts'], // No need for null check
      displayAllQuestionsOnOnePage:
          json['display_all_questions_on_one_page'] ?? false, // Initialize it
      total_questions: json['total_questions'] ?? 0,
      show_questions_counter:
          json['show_questions_counter'] ?? false, // Initialize it
      enable_navigation_bar: json['enable_navigation_bar'] ?? false,
      enable_live_progress_bar: json['enable_live_progress_bar'] ?? false,
      show_questions_category: json['show_questions_category'] ?? false,
      enable_timer: json['enable_timer'] ?? false,
      red_timer: json['red_timer'],
      timer_seconds: json['timer_seconds'],
      flashing_timer: json['flashing_timer'],
      published_status: json['published_status'],
      schedule_quiz: json['schedule_quiz'],
      message_if_unpublished: json['message_if_unpublished'],
      start_date: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      end_date:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      show_start_date_on_my_quiz: json['show_start_date_on_my_quiz'],
      show_start_date_counter_on_my_quiz:
          json['show_start_date_counter_on_my_quiz'],
      show_end_date_on_my_quiz: json['show_end_date_on_my_quiz'],
      show_end_date_counter_on_my_quiz:
          json['show_end_date_counter_on_my_quiz'],
      display_pass_fail_status: json['display_pass_fail_status'],
      display_score_table: json['display_score_table'],
      display_percentage_marks: json['display_percentage_marks'],
      display_correct_answers_on_result_page:
          json['display_correct_answers_on_result_page'],
      display_unattempted_answers_on_result_page:
          json['display_unattempted_answers_on_result_page'],
      display_wrong_answers_on_result_page:
          json['display_wrong_answers_on_result_page'],
      show_question_explanation_with_result:
          json['show_question_explanation_with_result'],
    );
  }
}

class UGQuizPage extends StatefulWidget {
  final String quizId;
  final String accessToken;
  final String title;
  final String description;
  final String quizImage;
  final int allowedAttempts;
  final int remainingAttempt;
  final bool displayAllQuestionsOnOnePage; // Add this attribute
  final int total_questions;
  final bool show_questions_counter;
  final bool enable_navigation_bar;
  final bool enable_live_progress_bar;
  final bool show_questions_category;
  final bool enable_timer;
  final int timer_seconds;
  final int flashing_timer;
  final int red_timer;
  final published_status;
  final schedule_quiz;
  final message_if_unpublished;
  final DateTime? start_date;
  final DateTime? end_date;
  final bool show_start_date_on_my_quiz;
  final bool show_end_date_on_my_quiz;
  final bool show_start_date_counter_on_my_quiz;
  final bool show_end_date_counter_on_my_quiz;
  final bool display_pass_fail_status;
  final bool display_score_table;
  final bool display_percentage_marks;
  final bool display_correct_answers_on_result_page;
  final bool display_unattempted_answers_on_result_page;
  final bool display_wrong_answers_on_result_page;
  final bool show_question_explanation_with_result;
  final String email;

  const UGQuizPage({
    Key? key,
    required this.quizId,
    required this.accessToken,
    required this.title,
    required this.description,
    required this.quizImage,
    required this.allowedAttempts,
    required this.remainingAttempt,
    required this.displayAllQuestionsOnOnePage, // Initialize it
    required this.total_questions,
    required this.show_questions_counter,
    required this.enable_navigation_bar,
    required this.enable_live_progress_bar,
    required this.show_questions_category,
    required this.enable_timer,
    required this.timer_seconds,
    required this.flashing_timer,
    required this.red_timer,
    required this.published_status,
    required this.schedule_quiz,
    required this.message_if_unpublished,
    required this.start_date,
    required this.end_date,
    required this.show_start_date_on_my_quiz,
    required this.show_end_date_on_my_quiz,
    required this.show_start_date_counter_on_my_quiz,
    required this.show_end_date_counter_on_my_quiz,
    required this.display_pass_fail_status,
    required this.display_score_table,
    required this.display_percentage_marks,
    required this.display_correct_answers_on_result_page,
    required this.display_unattempted_answers_on_result_page,
    required this.display_wrong_answers_on_result_page,
    required this.show_question_explanation_with_result,
    required this.email,
  }) : super(key: key);

  @override
  _UGQuizPageState createState() => _UGQuizPageState();
}

class _UGQuizPageState extends State<UGQuizPage> {
  late Map<String, dynamic> quizData = {}; // Initialize quizData here
  bool _isLoading = false; // Loading indicator state

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String formattedDuration = '';

    if (duration.inDays >= 365) {
      formattedDuration += '${duration.inDays ~/ 365} Years ';
      duration -= Duration(days: (duration.inDays ~/ 365) * 365);
    }

    if (duration.inDays >= 30) {
      formattedDuration += '${duration.inDays ~/ 30} Months ';
      duration -= Duration(days: (duration.inDays ~/ 30) * 30);
    }

    if (duration.inDays > 0) {
      formattedDuration += '${duration.inDays} Days ';
      duration -= Duration(days: duration.inDays);
    }

    if (duration.inHours > 0) {
      formattedDuration += '${duration.inHours} Hours ';
      duration -= Duration(hours: duration.inHours);
    }

    if (duration.inMinutes > 0) {
      formattedDuration += '${duration.inMinutes} Minutes ';
      duration -= Duration(minutes: duration.inMinutes);
    }

    formattedDuration += '${duration.inSeconds} Seconds';

    return formattedDuration;
  }

  String formatStartDateCounter() {
    if (widget.start_date == null) {
      return 'Start Date Not Set';
    } else {
      Duration difference = widget.start_date!.difference(DateTime.now());
      if (difference.isNegative) {
        return 'Quiz Started';
      } else {
        return 'Quiz starts in ${formatDuration(difference.inSeconds)}';
      }
    }
  }

  String formatEndDateCounter() {
    if (widget.end_date == null) {
      return 'End Date Not Set';
    } else {
      Duration difference = widget.end_date!.difference(DateTime.now());
      if (difference.isNegative) {
        return 'Quiz has been Expired';
      } else {
        return 'Quiz will be expiring in ${formatDuration(difference.inSeconds)}';
      }
    }
  }

  Future<void> _startQuiz() async {
    setState(() {
      _isLoading = true;
    });

    // Prepare quiz result data
    Map<String, dynamic> payload = Jwt.parseJwt(widget.accessToken);
    String? userUUID = payload['user_id']; // Adjust key to 'user_id'

    print('User UUID: $userUUID');

    Map<String, dynamic> quizAttempt = {
      'user': userUUID,
      'quiz': widget.quizId,
      'attempt_counter': 1, // Initialize attempt_counter to 1
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/quiz_attempts/'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(quizAttempt),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Quiz attempt submitted/updated successfully');
      } else {
        print(
            'Failed to submit quiz attempt: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }

    if (quizData['questions'] != null && quizData['questions'].isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => widget.displayAllQuestionsOnOnePage
              ? UGAQOSPQuizQuestionsPage(
                  quizData: quizData,
                  accessToken: widget.accessToken,
                  displayAllQuestionsOnOnePage:
                      widget.displayAllQuestionsOnOnePage,
                  total_questions: widget.total_questions,
                  enable_navigation_bar: widget.enable_navigation_bar,
                  show_questions_counter: widget.show_questions_counter,
                  enable_live_progress_bar: widget.enable_live_progress_bar,
                  show_questions_category: widget.show_questions_category,
                  enable_timer: widget.enable_timer,
                  timer_seconds: widget.timer_seconds,
                  flashing_timer: widget.flashing_timer,
                  red_timer: widget.red_timer,
                  display_pass_fail_status: widget.display_pass_fail_status,
                  display_score_table: widget.display_score_table,
                  display_percentage_marks: widget.display_percentage_marks,
                  display_correct_answers_on_result_page:
                      widget.display_correct_answers_on_result_page,
                  display_unattempted_answers_on_result_page:
                      widget.display_unattempted_answers_on_result_page,
                  display_wrong_answers_on_result_page:
                      widget.display_wrong_answers_on_result_page,
                  show_question_explanation_with_result:
                      widget.show_question_explanation_with_result,
                  email: widget.email,
                )
              : UGOQPPQuizQuestionsPage(
                  quizData: quizData,
                  accessToken: widget.accessToken,
                  displayAllQuestionsOnOnePage:
                      widget.displayAllQuestionsOnOnePage,
                  enable_navigation_bar: widget.enable_navigation_bar,
                  total_questions: widget.total_questions,
                  show_questions_counter: widget.show_questions_counter,
                  enable_live_progress_bar: widget.enable_live_progress_bar,
                  show_questions_category: widget.show_questions_category,
                  enable_timer: widget.enable_timer,
                  timer_seconds: widget.timer_seconds,
                  flashing_timer: widget.flashing_timer,
                  red_timer: widget.red_timer,
                  display_pass_fail_status: widget.display_pass_fail_status,
                  display_score_table: widget.display_score_table,
                  display_percentage_marks: widget.display_percentage_marks,
                  display_correct_answers_on_result_page:
                      widget.display_correct_answers_on_result_page,
                  display_unattempted_answers_on_result_page:
                      widget.display_unattempted_answers_on_result_page,
                  display_wrong_answers_on_result_page:
                      widget.display_wrong_answers_on_result_page,
                  show_question_explanation_with_result:
                      widget.show_question_explanation_with_result,
                  email: widget.email,
                ),
        ),
      );
    } else {
      print('No questions found');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _questionsfind() async {
    // Prepare quiz result data
    Map<String, dynamic> payload = Jwt.parseJwt(widget.accessToken);
    String? userUUID = payload['user_id']; // Adjust key to 'user_id'

    print('User UUID: $userUUID');

    try {
      final response = await http.get(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/get-quiz-questions/${widget.quizId}/'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('message')) {
          print(responseData['message']);
          // Handle message here
        } else {
          setState(() {
            quizData = responseData;
          });

          print('Quiz Data: $quizData');

          // Print UIDs for questions
          quizData['questions'].asMap().forEach((index, question) {
            print('Question $index UID: ${question['question_id']}');

            // Print UIDs for answers
            question['answers'].forEach((answer) {
              print('Answer UID for question $index: ${answer['uid']}');
            });
          });
        }
      } else {
        throw Exception('Failed to fetch quiz data');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _questionsfind();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    String formattedStartDate = widget.start_date != null
        ? DateFormat('dd-MMMM-yyyy (HH:mm:ss z)')
            .format(widget.start_date!.toLocal())
        : 'Start Date Not Set';

    String formattedEndDate = widget.end_date != null
        ? DateFormat('dd-MMMM-yyyy (HH:mm:ss z)')
            .format(widget.end_date!.toLocal())
        : 'End Date Not Set';

    String startText;
    if (widget.start_date != null) {
      if (widget.start_date!.isAfter(now)) {
        startText = 'Quiz will be starting on: $formattedStartDate';
      } else {
        startText = 'Quiz started on: $formattedStartDate';
      }
    } else {
      startText = 'Start Date Not Set';
    }

    String endText;
    if (widget.end_date != null) {
      if (widget.end_date!.isAfter(now)) {
        endText = 'Quiz will be ending on: $formattedEndDate';
      } else {
        endText = 'Quiz has been expired since: $formattedEndDate';
      }
    } else {
      endText = 'End Date Not Set';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(widget.quizImage),
            SizedBox(height: 20),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal:
                      15.0), // Adjust the horizontal padding value as needed
              child: Container(
                width: MediaQuery.of(context).size.width -
                    30.0, // Subtract the horizontal padding from the width
                child: Text(
                  '${widget.description}',
                  style: TextStyle(color: Color.fromARGB(255, 86, 86, 86)),
                ),
              ),
            ),
            if (widget.enable_timer) SizedBox(height: 10),
            if (widget.enable_timer)
              Text(
                'Total Time: ${formatDuration(widget.timer_seconds)}',
              ),
            SizedBox(height: 8),
            Text(
              'Allowed Attempts: ${widget.allowedAttempts}',
            ),
            SizedBox(height: 8),
            Text(
              'Remaining Attempts: ${widget.remainingAttempt}',
            ),
            SizedBox(height: 8),
            if (widget.show_questions_counter)
              Text(
                'Number of Questions: ${widget.total_questions}',
              ),
            if (widget.show_start_date_on_my_quiz &&
                widget.start_date != null &&
                widget.start_date!.isAfter(now))
              SizedBox(height: 20),
            if (widget.show_start_date_on_my_quiz &&
                widget.start_date != null &&
                widget.start_date!.isAfter(now))
              Text(startText),
            if (widget.show_end_date_on_my_quiz &&
                widget.start_date != null &&
                widget.start_date!.isBefore(now))
              SizedBox(height: 20),
            if (widget.show_end_date_on_my_quiz &&
                widget.start_date != null &&
                widget.start_date!.isBefore(now))
              Text(endText),
            if (widget.show_start_date_counter_on_my_quiz &&
                widget.start_date != null &&
                widget.start_date!.isAfter(now))
              SizedBox(height: 20),
            if (widget.show_start_date_counter_on_my_quiz &&
                widget.start_date != null &&
                widget.start_date!.isAfter(now))
              Text(
                'Quiz Starting in',
              ),
            if (widget.show_start_date_counter_on_my_quiz &&
                widget.start_date != null &&
                widget.start_date!.isAfter(now))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CountdownBox(
                    label: 'Days',
                    endDate: widget.start_date,
                  ),
                  CountdownBox(
                    label: 'Hours',
                    endDate: widget.start_date,
                  ),
                  CountdownBox(
                    label: 'Minutes',
                    endDate: widget.start_date,
                  ),
                  CountdownBox(
                    label: 'Seconds',
                    endDate: widget.start_date,
                  ),
                ],
              ),
            if (widget.show_end_date_counter_on_my_quiz &&
                widget.end_date != null &&
                widget.end_date!.isAfter(now))
              SizedBox(height: 20),
            if (widget.show_end_date_counter_on_my_quiz &&
                widget.end_date != null &&
                widget.end_date!.isAfter(now))
              Text(
                'Quiz ending in',
              ),
            if (widget.show_end_date_counter_on_my_quiz &&
                widget.end_date != null &&
                widget.end_date!.isAfter(now))
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CountdownBox(
                    label: 'Days',
                    endDate: widget.end_date,
                  ),
                  CountdownBox(
                    label: 'Hours',
                    endDate: widget.end_date,
                  ),
                  CountdownBox(
                    label: 'Minutes',
                    endDate: widget.end_date,
                  ),
                  CountdownBox(
                    label: 'Seconds',
                    endDate: widget.end_date,
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.published_status)
              widget.remainingAttempt > 0
                  ? Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true; // Show loading indicator
                          });
                          await _questionsfind();
                          await _startQuiz();
                          setState(() {
                            _isLoading = false; // Hide loading indicator
                          });
                        },
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : Text('Start Quiz'),
                      ),
                    )
                  : Text(
                      'Maximum attempts reached',
                      style: TextStyle(color: Colors.red),
                    )
            else
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  '${widget.message_if_unpublished}',
                  style: TextStyle(color: Colors.red),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

class CountdownBox extends StatefulWidget {
  final String label;
  final DateTime? endDate;
  const CountdownBox({
    Key? key,
    required this.label,
    required this.endDate,
  }) : super(key: key);

  @override
  _CountdownBoxState createState() => _CountdownBoxState();
}

class _CountdownBoxState extends State<CountdownBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = 0; // Initialize _value
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(_updateValue);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue() {
    Duration difference = widget.endDate!.difference(DateTime.now());
    setState(() {
      switch (widget.label) {
        case 'Days':
          _value = difference.inDays;
          break;
        case 'Hours':
          _value = difference.inHours % 24;
          break;
        case 'Minutes':
          _value = difference.inMinutes % 60;
          break;
        case 'Seconds':
          _value = difference.inSeconds % 60;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            _value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
