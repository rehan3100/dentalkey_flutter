import 'package:dental_key/dental_portal/services/foreign_exams/ResultPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'dart:async';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'dart:io';

class OQPPQuizQuestionsPage extends StatefulWidget {
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

  const OQPPQuizQuestionsPage({
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
  _OQPPQuizQuestionsPageState createState() => _OQPPQuizQuestionsPageState();
}

class _OQPPQuizQuestionsPageState extends State<OQPPQuizQuestionsPage> {
  late List<List<String>> selectedAnswers;
  final ValueNotifier<String> filterNotifier = ValueNotifier<String>('All');
  bool _isSubmitting = false;
  int _currentPage = 0;
  late int _timerSeconds;
  late Timer _timer;
  late Timer _flashingTimer;
  bool _isRedTimer = false;
  bool _isFlashing = false;
  bool _quizSubmitted = false;
  String quizResultUid = '';

  @override
  void initState() {
    super.initState();
    _enableScreenshotRestriction(); // Add this line

    if (widget.quizData['questions'] == null) {
      widget.quizData['questions'] = [];
    }

    selectedAnswers = List<List<String>>.generate(
      widget.quizData['questions'].length,
      (index) => [],
    );
    for (int i = 0; i < widget.quizData['questions'].length; i++) {
      widget.quizData['questions'][i]['originalIndex'] = i;
    }
    if (!_quizSubmitted && widget.timer_seconds > 0 && widget.enable_timer) {
      _timerSeconds = widget.timer_seconds;

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_timerSeconds > 0) {
          setState(() {
            _timerSeconds -= 1;
            if (_timerSeconds == widget.red_timer) {
              _isRedTimer = true;
            }
          });
        } else {
          _timer.cancel();
          if (!_quizSubmitted) {
            _submitQuiz();
          }
        }
      });

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
    _timer.cancel();
    _flashingTimer.cancel();
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
    setState(() {
      _isSubmitting = true;
    });

    if (!_quizSubmitted) {
      _quizSubmitted = true;

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
        'unattemptedquestion_set': [],
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
          Map<String, dynamic> responseData = jsonDecode(response.body);
          quizResultUid = responseData['uid'];
          print('quiz uuid: $quizResultUid');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FEResultPage(
                accessToken: widget.accessToken,
                quizResultUid: {'uid': quizResultUid},
                quizResult: quizResult,
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

    // Debugging print statement
    print('Filtered questions count: ${filteredQuestions.length}');
    filteredQuestions.forEach((q) {
      print('Filtered question ID: ${q['question_id']}');
    });

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
          title: Text('POSTGRADUATE EXAM'),
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
        body: Stack(
          children: [
            Column(
              children: [
                if (widget.enable_timer) SizedBox(width: 10),
                if (widget.enable_timer)
                  CountdownTimer(
                    endTime: DateTime.now().millisecondsSinceEpoch +
                        _timerSeconds * 1000,
                    textStyle: TextStyle(
                      fontSize: 24,
                      color: _timerSeconds > widget.red_timer
                          ? Colors.blue
                          : (_timerSeconds > widget.flashing_timer)
                              ? Colors.red
                              : (_isFlashing &&
                                      _timerSeconds <= widget.flashing_timer)
                                  ? Color.fromARGB(255, 255, 0, 0)
                                  : Color.fromARGB(255, 255, 255, 255),
                    ),
                    onEnd: () {
                      print('Timer ended');
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
                      SizedBox(width: 10),
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
                            onPressed: () => _showQuestionJumpModal(
                                filteredQuestions.length),
                            child: Text('Jump to'),
                          ),
                        ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          child: Text('Submit'),
                          onPressed: _submitQuiz,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isSubmitting)
              ModalBarrier(
                color: Colors.black.withOpacity(0.5),
                dismissible: false,
              ),
            if (_isSubmitting)
              Center(
                child: CircularProgressIndicator(),
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

    // Debugging print statement
    print('Rendering question: ${question['question_id']}');

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          if (widget.show_questions_counter)
            Text(
              'Question ${question['originalIndex'] + 1} of ${widget.total_questions}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          if (widget.show_questions_category)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Question Category: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '${question['category']}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            color: const Color.fromARGB(255, 237, 237, 237),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marks: ${question['marks'] ?? ""}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Question: ${question['question_text'] ?? ""}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                  SizedBox(height: 20),
                  Text(
                    'Options:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      question['answers']?.length ?? 0,
                      (answerIndex) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            border: Border.all(
                                color: const Color.fromARGB(255, 66, 66, 66)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
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
              bool attempted = selectedAnswers[index].isNotEmpty;
              return ListTile(
                title: Text(
                  'Question ${index + 1}',
                  style: TextStyle(
                    color: attempted ? Colors.green : Colors.red,
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
        List<Map<String, dynamic>>.from(widget.quizData['questions'] ?? []);

    // Debugging print statement
    print('Original questions count: ${originalQuestions.length}');
    originalQuestions.forEach((q) {
      print('Original question ID: ${q['question_id']}');
    });

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
