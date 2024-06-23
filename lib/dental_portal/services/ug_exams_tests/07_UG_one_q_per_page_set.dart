import 'package:dental_key/dental_portal/services/ug_exams_tests/ResultPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'dart:async';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'dart:io';

class UGOQPPQuizQuestionsPage extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final String accessToken;
  final bool displayAllQuestionsOnOnePage;
  final bool enable_navigation_bar;
  final int total_questions;
  final bool show_questions_counter;
  final bool enable_live_progress_bar;
  final bool show_questions_category;
  final bool enable_timer;
  final int timer_seconds;
  final int flashing_timer;
  final int red_timer;
  final bool display_pass_fail_status;
  final bool display_score_table;
  final bool display_percentage_marks;
  final bool display_correct_answers_on_result_page;
  final bool display_unattempted_answers_on_result_page;
  final bool display_wrong_answers_on_result_page;
  final bool show_question_explanation_with_result;
  final String email;
  const UGOQPPQuizQuestionsPage({
    Key? key,
    required this.quizData,
    required this.accessToken,
    required this.displayAllQuestionsOnOnePage,
    required this.enable_navigation_bar,
    required this.total_questions,
    required this.show_questions_counter,
    required this.enable_live_progress_bar,
    required this.show_questions_category,
    required this.enable_timer,
    required this.timer_seconds,
    required this.flashing_timer,
    required this.red_timer,
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
  _UGOQPPQuizQuestionsPageState createState() =>
      _UGOQPPQuizQuestionsPageState();
}

class _UGOQPPQuizQuestionsPageState extends State<UGOQPPQuizQuestionsPage> {
  late List<List<String>> selectedAnswers;
  final ValueNotifier<String> filterNotifier = ValueNotifier<String>('All');
  bool _isSubmitting = false;
  int _currentPage = 0;
  late int _timerSeconds;
  late Timer _timer;
  late Timer _flashingTimer;
  bool _isRedTimer = false;
  bool _isFlashing = false;
  bool _quizSubmitted = false; // Add this flag
  String quizResultUid = ''; // Define quizResultUid here

  @override
  void initState() {
    super.initState();
    _enableScreenshotRestriction(); // Add this line

    selectedAnswers = List<List<String>>.generate(
      widget.quizData['questions'].length,
      (index) => [],
    );
    for (int i = 0; i < widget.quizData['questions'].length; i++) {
      widget.quizData['questions'][i]['originalIndex'] = i;
    }
    if (!_quizSubmitted && widget.timer_seconds > 0 && widget.enable_timer) {
      _timerSeconds = widget.timer_seconds;

      // Timer for decrementing timerSeconds by one second
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_timerSeconds > 0) {
          setState(() {
            _timerSeconds -= 1;
            if (_timerSeconds == widget.red_timer) {
              _isRedTimer = true;
            }
          });
        } else {
          _timer.cancel(); // Cancel timer when it reaches 0
          if (!_quizSubmitted) {
            _submitQuiz(); // Call _submitQuiz() when timer reaches 0
          }
        }
      });

      // Timer for toggling flashing state every half-second within the flashing range
      _flashingTimer = Timer.periodic(Duration(milliseconds: 400), (timer) {
        if (_timerSeconds > 0 && _timerSeconds <= widget.flashing_timer) {
          setState(() {
            _isFlashing = !_isFlashing;
          });
        }
      });
    }
  }

  Future<void> _enableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer when disposing of the widget
    _flashingTimer
        .cancel(); // Cancel flashing timer when disposing of the widget
    _disableScreenshotRestriction(); // Add this line

    super.dispose();
  }

  Future<void> _disableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  void _sendSelectedAnswer(String questionId, String selectedAnswerId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/save-selected-answer/'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'quiz_id': widget.quizData['quiz_id'],
            'question_id': questionId,
            'selected_answer_id': selectedAnswerId,
          },
        ),
      );

      if (response.statusCode == 201) {
        print('Selected answer submitted successfully');
      } else {
        print(
            'Failed to submit selected answer: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _submitQuiz() async {
    if (!_quizSubmitted) {
      _quizSubmitted = true; // Add this flag

      Map<String, dynamic> payload = Jwt.parseJwt(widget.accessToken);
      String? userUUID = payload['user_id'];

      Map<String, dynamic> quizResult = {
        'user': userUUID,
        'quiz': widget.quizData['quiz_id'],
        'total_questions': widget.quizData['questions'].length,
        'correct_questions': 0,
        'wrong_questions': 0,
        'unanswered_questions': 0,
        'attemptedquestion_set': [],
        'unattemptedquestion_set': [], // Add this field
      };

      for (int i = 0; i < widget.quizData['questions'].length; i++) {
        Map<String, dynamic> question = widget.quizData['questions'][i];
        List<String> selectedAnswerUUIDs = selectedAnswers[i];

        if (selectedAnswerUUIDs.isEmpty) {
          quizResult['unattemptedquestion_set'].add({
            'question': question['question_id'],
            'selected_answer': '',
            'is_correct': false,
          });
        } else {
          List<Map<String, dynamic>> attemptedQuestions = selectedAnswerUUIDs
              .map(
                (selectedAnswerUUID) => {
                  'question': question['question_id'],
                  'selected_answer': selectedAnswerUUID,
                  'is_correct': question['answers']
                      .where((answer) =>
                          answer['uid'] == selectedAnswerUUID &&
                          answer['is_correct'] == true)
                      .isNotEmpty,
                },
              )
              .toList();
          quizResult['attemptedquestion_set'].addAll(attemptedQuestions);
        }
      }

      try {
        final response = await http.post(
          Uri.parse(
              'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/save-quiz-result/'),
          headers: {
            'Authorization': 'Bearer ${widget.accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(quizResult),
        );

        if (response.statusCode == 201) {
          print('Quiz result submitted successfully');
          // Parse the response to get quiz_result.uid
          Map<String, dynamic> responseData = jsonDecode(response.body);
          quizResultUid = responseData['uid']; // Assign quizResultUid here
          print('quiz uuid: $quizResultUid');

          // Navigate to quiz result page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UGResultPage(
                accessToken: widget.accessToken,
                quizResultUid: {
                  'uid': quizResultUid
                }, // Pass quiz_result.uid as Map<String, dynamic>
                quizResult: quizResult, // Pass quizResult object
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
          print(
              'Failed to submit quiz result: ${response.statusCode} - ${response.body}');
        }
      } catch (error) {
        print('Error: $error');
      }
    }
    setState(() {
      _isSubmitting = false;
    });
  }

  List<Map<String, dynamic>> _getAttemptedQuestions() {
    List<Map<String, dynamic>> attemptedQuestions = [];

    for (int i = 0; i < widget.quizData['questions'].length; i++) {
      Map<String, dynamic> question = widget.quizData['questions'][i];
      List<String> selectedAnswerUUIDs = selectedAnswers[i];
      List<Map<String, dynamic>> attemptedQuestion = selectedAnswerUUIDs
          .map(
            (selectedAnswerUUID) => {
              'question': question['question_id'],
              'selected_answer': selectedAnswerUUID,
              'is_correct': question['answers']
                      .where((answer) =>
                          answer['uid'] == selectedAnswerUUID &&
                          answer['is_correct'] == true)
                      .isNotEmpty
                  ? true
                  : false,
            },
          )
          .toList();
      attemptedQuestions.addAll(attemptedQuestion);
    }

    return attemptedQuestions;
  }

  List<Map<String, dynamic>> _getUnattemptedQuestions() {
    List<Map<String, dynamic>> unattemptedQuestions = [];

    for (int i = 0; i < widget.quizData['questions'].length; i++) {
      Map<String, dynamic> question = widget.quizData['questions'][i];
      if (selectedAnswers[i].isEmpty) {
        unattemptedQuestions.add({
          'question': question['question_id'],
        });
      }
    }

    return unattemptedQuestions;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredQuestions =
        _filterQuestions(filterNotifier.value);

    if (_currentPage >= filteredQuestions.length) {
      _currentPage =
          filteredQuestions.isEmpty ? 0 : filteredQuestions.length - 1;
    }

    double progress =
        selectedAnswers.where((answers) => answers.isNotEmpty).length /
            widget.total_questions;
    int percentage = (progress * 100).toInt();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('UNDERGRADUATE TEST'),
          automaticallyImplyLeading: false,
          actions: [
            ValueListenableBuilder<String>(
              valueListenable: filterNotifier,
              builder: (context, value, child) {
                return PopupMenuButton<String>(
                  onSelected: (String value) {
                    filterNotifier.value = value;
                    _resetCurrentPage();
                  },
                  itemBuilder: (BuildContext context) => [
                    _buildFilterPopupMenuItem('All', value),
                    _buildFilterPopupMenuItem('Unattempted', value),
                    _buildFilterPopupMenuItem('Attempted', value),
                  ],
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (widget.enable_timer) SizedBox(width: 10),
            if (widget.enable_timer &&
                _timerSeconds != null) // Added null check
              CountdownTimer(
                endTime: DateTime.now().millisecondsSinceEpoch +
                    _timerSeconds! * 1000, // Added null check
                textStyle: TextStyle(
                  fontSize: 24,
                  color: _timerSeconds! > widget.red_timer
                      ? Colors.blue
                      : (_timerSeconds! > widget.flashing_timer)
                          ? Colors.red
                          : (_isFlashing &&
                                  _timerSeconds! <=
                                      widget
                                          .flashing_timer) // Check both conditions
                              ? Color.fromARGB(
                                  255, 255, 0, 0) // Flashing color 1 (white)
                              : Color.fromARGB(
                                  255, 255, 255, 255), // Flashing color 2 (red)
                ),
                onEnd: () {
                  print('Timer ended');
                  // You can add code to handle timer end here
                },
              ),
            if (widget.enable_live_progress_bar) SizedBox(width: 10),
            if (widget.enable_live_progress_bar)
              LinearPercentIndicator(
                animation: true,
                lineHeight: 20.0,
                animationDuration: 1000,
                percent: progress,
                center: Text(
                  '$percentage%',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: const Color.fromARGB(255, 11, 200, 108),
                backgroundColor: Colors.red,
              ),
            if (filteredQuestions.isNotEmpty)
              Expanded(
                child: _buildQuizQuestions(filteredQuestions),
              )
            else
              Expanded(
                child: Center(
                  child: Text("No questions found"),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      child: Text('Previous'),
                    ),
                  ),
                  SizedBox(width: 10), // Add some space between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage < filteredQuestions.length - 1
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      child: Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  if (widget.enable_navigation_bar &&
                      widget.show_questions_counter)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _showQuestionJumpModal(filteredQuestions.length),
                        child: Text('Jump to'),
                      ),
                    ),
                  SizedBox(width: 10), // Add some space between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitQuiz,
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildFilterPopupMenuItem(
      String itemValue, String currentValue) {
    return PopupMenuItem<String>(
      value: itemValue,
      child: Text(
        itemValue,
        style: TextStyle(
          color: currentValue == itemValue ? Colors.blue : null,
          fontWeight: currentValue == itemValue ? FontWeight.bold : null,
        ),
      ),
    );
  }

  void _resetCurrentPage() {
    setState(() {
      _currentPage = 0;
    });
  }

  Widget _buildQuizQuestions(List<Map<String, dynamic>> filteredQuestions) {
    Map<String, dynamic> question = filteredQuestions[_currentPage];

    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.show_questions_counter)
            Text(
              'Question ${question['originalIndex'] + 1} of ${widget.total_questions}',
            ),
          if (widget.show_questions_category)
            Padding(
              padding: EdgeInsets.all(8.0), // Add padding of 8.0 to all sides
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Question Category: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: '${question['category']}',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Marks: ${question['marks'] ?? ""}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${question['question_text'] ?? ""}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (question['question_image'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.network(
                        question['question_image'].startsWith('http')
                            ? question['question_image']
                            : 'https://dental-key-738b90a4d87a.herokuapp.com${question['question_image']}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      question['answers']?.length ?? 0,
                      (answerIndex) {
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (question['answers'][answerIndex]
                                      ['answer_image'] !=
                                  null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Image.network(
                                    question['answers'][answerIndex]
                                                ['answer_image']
                                            .startsWith('http')
                                        ? question['answers'][answerIndex]
                                            ['answer_image']
                                        : 'https://dental-key-738b90a4d87a.herokuapp.com${question['answers'][answerIndex]['answer_image']}',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Text(
                                '${question['answers'][answerIndex]['answer'] ?? ""}',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: _buildAnswerWidget(
                            question['question_type'] ?? "",
                            question['answers'][answerIndex]['uid'] ?? "",
                            question['originalIndex'] ?? 0,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionJumpModal(int numberOfQuestions) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.builder(
            itemCount: numberOfQuestions,
            itemBuilder: (BuildContext context, int index) {
              bool attempted = selectedAnswers[index]
                  .isNotEmpty; // Check if question is attempted
              return ListTile(
                title: Text(
                  'Question ${index + 1}',
                  style: TextStyle(
                    color: attempted
                        ? Colors.green
                        : Colors.red, // Change text color based on attempt
                  ),
                ),
                onTap: () {
                  setState(() {
                    _currentPage = index;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnswerWidget(
      String questionType, String answerUid, int questionIndex) {
    switch (questionType) {
      case 'Radio':
        return Radio(
          value: answerUid,
          groupValue: selectedAnswers[questionIndex].isNotEmpty
              ? selectedAnswers[questionIndex][0]
              : null,
          onChanged: (value) {
            setState(() {
              selectedAnswers[questionIndex] = [value as String];
              _sendSelectedAnswer(
                widget.quizData['questions'][questionIndex]['question_id'],
                value as String,
              );
            });
          },
        );
      case 'Checkbox_partial_marks':
      case 'Checkbox_yesno_marks':
        return Checkbox(
          value: selectedAnswers[questionIndex].contains(answerUid),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selectedAnswers[questionIndex].add(answerUid);
              } else {
                selectedAnswers[questionIndex].remove(answerUid);
              }
            });
            _sendSelectedAnswer(
              widget.quizData['questions'][questionIndex]['question_id'],
              answerUid,
            );
          },
        );
      default:
        return SizedBox();
    }
  }

  List<Map<String, dynamic>> _filterQuestions(String filter) {
    List<Map<String, dynamic>> originalQuestions =
        List<Map<String, dynamic>>.from(widget.quizData['questions']);

    switch (filter) {
      case 'All':
        return originalQuestions;
      case 'Attempted':
        return originalQuestions
            .where((question) =>
                selectedAnswers[question['originalIndex']].isNotEmpty)
            .toList();
      case 'Unattempted':
        return originalQuestions
            .where((question) =>
                selectedAnswers[question['originalIndex']].isEmpty)
            .toList();
      default:
        return [];
    }
  }
}
