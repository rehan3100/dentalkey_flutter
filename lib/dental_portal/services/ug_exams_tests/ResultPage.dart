import 'dart:convert';
import 'package:dental_key/dental_portal/mainscreen/dental-account.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'dart:io';

class UGResultPage extends StatefulWidget {
  final String accessToken;
  final Map<String, dynamic> quizResultUid;
  final Map<String, dynamic> quizResult;
  final bool display_pass_fail_status;
  final bool display_score_table;
  final bool display_percentage_marks;
  final bool display_correct_answers_on_result_page;
  final bool display_unattempted_answers_on_result_page;
  final bool display_wrong_answers_on_result_page;
  final bool show_question_explanation_with_result;
  final String email;
  const UGResultPage({
    Key? key,
    required this.accessToken,
    required this.quizResultUid,
    required this.quizResult,
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
  _UGResultPageState createState() =>
      _UGResultPageState(accessToken: accessToken);
}

class _UGResultPageState extends State<UGResultPage> {
  final String accessToken;
  _UGResultPageState({required this.accessToken});

  Map<String, dynamic>? _quizResult;
  late ConfettiController _confettiController;
  bool passed = true;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _fetchQuizResult();
    _enableScreenshotRestriction(); // Add this line
  }

  Future<void> _enableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _disableScreenshotRestriction(); // Add this line
    super.dispose();
  }

  Future<void> _disableScreenshotRestriction() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  Future<void> _fetchQuizResult() async {
    final url = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/get-quiz-result/${widget.quizResultUid['uid']}/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      setState(() {
        _quizResult = decodedResponse['quiz'];
        passed = _quizResult!['status_pass_fail'] ==
            'PASS'; // Set passed variable based on status_pass_fail
        print(
            'status_pass_fail: ${_quizResult!['status_pass_fail']}'); // Add this line to print the value
      });

      // Fetch question details for attempted questions
      await _fetchQuestionDetails(
          _quizResult!['quiz_questions']['attempted_questions']);
      // Fetch question details for unattempted questions
      await _fetchQuestionDetails(
          _quizResult!['quiz_questions']['unattempted_questions']);
      // Fetch questions with selected answers
      final questionsWithSelectedAnswers =
          await fetchQuestionsWithSelectedAnswers(widget.quizResultUid['uid']);
      print('Questions with selected answers: $questionsWithSelectedAnswers');
      _confettiController.play(); // Start confetti animation
    } else {
      throw Exception('Failed to load quiz result');
    }
  }

  String formatUrl(String url) {
    if (!url.startsWith('http')) {
      return 'https://dental-key-738b90a4d87a.herokuapp.com$url';
    }
    return url;
  }

  Future<Map<String, dynamic>> fetchQuestionsWithSelectedAnswers(
      String quizResultUid) async {
    final url = Uri.parse(
        'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/get-questions-with-selected-answers/$quizResultUid/');
    print('Fetching data from: $url'); // Adding print statement
    final response = await http.get(url);
    print(
        'Response status code: ${response.statusCode}'); // Adding print statement
    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Adding print statement
      return json.decode(response.body);
    } else {
      print(
          'Failed to load questions with selected answers'); // Adding print statement
      throw Exception('Failed to load questions with selected answers');
    }
  }

  Future<void> _fetchQuestionDetails(List<dynamic> questions) async {
    for (var questionData in questions) {
      final questionUid = questionData['question'];
      final url = Uri.parse(
          'https://dental-key-738b90a4d87a.herokuapp.com/quizzer/get-question-details/$questionUid/');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final questionDetails = json.decode(response.body);
        setState(() {
          questionData['question_text'] = questionDetails['question'];
          questionData['explanation'] = questionDetails['explanation'];
          questionData['question_image'] =
              questionDetails['question_image'] != null
                  ? formatUrl(questionDetails['question_image'])
                  : null;
          questionData['answers'] = questionDetails['answers'];
          // Correctly construct URL for answer images
          (questionData['answers'] as List).forEach((answer) {
            answer['answer_image'] = answer['answer_image'] != null
                ? formatUrl(answer['answer_image'])
                : null;
          });
        });
      } else {
        throw Exception('Failed to load question details');
      }
    }
  }

  Widget _buildResultView() {
    double percentage =
        double.parse('${_quizResult!['percentage'] ?? '0'}') / 100;
    double correctPercentage =
        double.parse('${_quizResult!['correct_questions'] ?? '0'}') /
            double.parse('${_quizResult!['total_questions'] ?? '1'}');
    double unansweredPercentage =
        double.parse('${_quizResult!['unanswered_questions'] ?? '0'}') /
            double.parse('${_quizResult!['total_questions'] ?? '1'}');
    double wrongPercentage =
        double.parse('${_quizResult!['wrong_questions'] ?? '0'}') /
            double.parse('${_quizResult!['total_questions'] ?? '1'}');
    bool passed = _quizResult!['status_pass_fail'] == 'PASS';
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                _quizResult!['quiz_title'] ?? '',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Column(
              children: [
                passed
                    ? Text(
                        'Congratulations!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : Text(
                        'Sorry!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                passed
                    ? Image.asset('assets/images/congrats_emoji.png',
                        width: 100, height: 100)
                    : Column(
                        children: [
                          Image.asset(
                            'assets/images/alas_emoji.jpg',
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: CircularPercentIndicator(
                      radius: 80.0,
                      lineWidth: 20.0,
                      percent: percentage,
                      center: Text(
                        '${(_quizResult!['percentage'] ?? '')}%',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Color(0xFFBD0000),
                      progressColor: Color(0xFF00AC48),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 150,
                      height: 80,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Color(0xFFBD0000),
                              value: (_quizResult?['wrong_questions'] ?? 0)
                                  .toDouble(),
                              title: '${_quizResult?['wrong_questions'] ?? 0}',
                              radius: 21,
                              titleStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBD0000),
                              ),
                              titlePositionPercentageOffset: -0.6,
                            ),
                            PieChartSectionData(
                              color: Color.fromARGB(255, 255, 247, 0),
                              value: (_quizResult?['unanswered_questions'] ?? 0)
                                  .toDouble(),
                              title:
                                  '${_quizResult?['unanswered_questions'] ?? 0}',
                              radius: 21,
                              titleStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 223, 215, 1),
                              ),
                              titlePositionPercentageOffset: -0.9,
                            ),
                            PieChartSectionData(
                              color: Color(0xFF00AC48),
                              value: (_quizResult?['correct_questions'] ?? 0)
                                  .toDouble(),
                              title:
                                  '${_quizResult?['correct_questions'] ?? 0}',
                              radius: 21,
                              titleStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00AC48),
                              ),
                              titlePositionPercentageOffset: -0.9,
                            ),
                          ],
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius:
                              60, // Adjust this value to increase central hollow space
                          sectionsSpace: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            if (widget.display_score_table)
              Card(
                elevation: 4,
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.display_pass_fail_status)
                        _buildResultRow('Status Pass/Fail',
                            _quizResult!['status_pass_fail']),
                      if (widget.display_percentage_marks)
                        _buildResultRow(
                            'Percentage', '${_quizResult!['percentage']}%'),
                      _buildResultRow(
                        'Obtained Marks',
                        _quizResult!['obtained_marks'],
                        'out of',
                        _quizResult!['total_marks'],
                      ),
                      _buildResultRow(
                        'Correct Questions',
                        _quizResult!['correct_questions'],
                        'out of',
                        _quizResult!['total_questions'],
                      ),
                      _buildResultRow(
                        'Wrong Questions',
                        _quizResult!['wrong_questions'],
                        'out of',
                        _quizResult!['total_questions'],
                      ),
                      _buildResultRow(
                        'Unanswered Questions',
                        _quizResult!['unanswered_questions'],
                        'out of',
                        _quizResult!['total_questions'],
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.display_correct_answers_on_result_page &&
                widget.display_wrong_answers_on_result_page)
              SizedBox(height: 20),
            if (widget.display_correct_answers_on_result_page &&
                widget.display_wrong_answers_on_result_page)
              Text(
                'Questions:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (widget.display_correct_answers_on_result_page &&
                widget.display_wrong_answers_on_result_page)
              SizedBox(height: 10),
            if (widget.display_correct_answers_on_result_page &&
                widget.display_wrong_answers_on_result_page)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attempted Questions:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (widget.display_correct_answers_on_result_page &&
                      widget.display_wrong_answers_on_result_page)
                    SizedBox(height: 10),
                  if (widget.display_correct_answers_on_result_page &&
                      widget.display_wrong_answers_on_result_page)
                    Column(
                      children: _quizResult!['quiz_questions']
                              ['attempted_questions']
                          .map<Widget>((questionData) =>
                              _buildQuestionCard(questionData, attempted: true))
                          .toList(),
                    ),
                  if (widget.display_unattempted_answers_on_result_page)
                    SizedBox(height: 20),
                  if (widget.display_unattempted_answers_on_result_page)
                    Text(
                      'Unattempted Questions:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  if (widget.display_unattempted_answers_on_result_page)
                    SizedBox(height: 10),
                  if (widget.display_unattempted_answers_on_result_page)
                    Column(
                      children: _quizResult!['quiz_questions']
                              ['unattempted_questions']
                          .map<Widget>((questionData) => _buildQuestionCard(
                              questionData,
                              attempted: false))
                          .toList(),
                    ),
                ],
              ),
          ],
        ),
        if (widget.display_correct_answers_on_result_page &&
            widget.display_wrong_answers_on_result_page &&
            widget.display_unattempted_answers_on_result_page)
          Align(
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -0.785398, // Rotate text by -45 degrees (in radians)
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color.fromARGB(100, 93, 179, 249),
                    Color.fromARGB(100, 195, 89, 89)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  widget.email,
                  style: TextStyle(
                    color: Colors
                        .white, // This color will be overridden by the gradient
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultRow(String title, dynamic data,
      [String? extraInfo, dynamic total]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            data != null
                ? extraInfo != null
                    ? '$data $extraInfo $total'
                    : data.toString()
                : '',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> questionData,
      {bool attempted = true}) {
    var questionText = questionData['question_text'] ?? '';
    var questionImage = questionData['question_image'] ?? '';
    var isCorrect = questionData['is_correct'] ?? false;
    var answers = questionData['answers'] ?? [];
    var selectedAnswerUid = questionData['selected_answer'];
    var correctAnswerUid = questionData['correct_answer'];

    return Card(
      color: const Color.fromARGB(255, 237, 237, 237),
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    questionText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.show_question_explanation_with_result)
                  IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () {
                      _showQuestionDetailsModal(questionData);
                    },
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (questionImage.isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    questionImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 8),
            Text(
              attempted
                  ? (isCorrect ? 'Correct' : 'Incorrect')
                  : 'Not Attempted',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: attempted
                    ? (isCorrect
                        ? Colors.green
                        : (selectedAnswerUid != null && !isCorrect)
                            ? Colors.red
                            : Colors.black)
                    : Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: answers.map<Widget>((answer) {
                var answerText = answer['answer'] ?? '';
                var answerImage = answer['answer_image'] ?? '';
                var isAnswerCorrect = answer['is_correct'] ?? false;
                return Container(
                  decoration: BoxDecoration(
                    color: isAnswerCorrect
                        ? const Color.fromARGB(255, 194, 255, 196)
                        : (selectedAnswerUid == answer['uid'] &&
                                !isAnswerCorrect)
                            ? Color.fromARGB(255, 255, 188, 188)
                            : Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: ListTile(
                    title: answerImage.isNotEmpty ? null : Text(answerText),
                    subtitle: answerImage.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    answerImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(answerText),
                            ],
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionDetailsModal(Map<String, dynamic> questionData) {
    var questionText = questionData['question_text'] ?? '';
    var questionImage = questionData['question_image'] ?? '';
    var explanation = questionData['explanation'] ?? '';
    var correctAnswer = questionData['answers']
        ?.firstWhere((answer) => answer['is_correct'] == true)['answer'];
    var selectedAnswer = questionData['selected_answer'] != null
        ? questionData['answers']?.firstWhere((answer) =>
            answer['uid'] == questionData['selected_answer'])['answer']
        : 'Not Attempted';
    var correctAnswerImage = questionData['answers']
        ?.firstWhere((answer) => answer['is_correct'] == true)['answer_image'];
    var selectedAnswerImage = questionData['selected_answer'] != null
        ? questionData['answers']?.firstWhere((answer) =>
            answer['uid'] == questionData['selected_answer'])['answer_image']
        : null;

    var modalContent = Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$questionText",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (questionImage.isNotEmpty) ...[
                SizedBox(height: 10),
                Image.network(questionImage),
              ],
              SizedBox(height: 10),
              Text(
                "Selected Answer:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("$selectedAnswer"),
              if (selectedAnswerImage != null) ...[
                SizedBox(height: 10),
                Image.network(selectedAnswerImage),
              ],
              SizedBox(height: 10),
              Text(
                "Correct Answer:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("$correctAnswer"),
              if (correctAnswerImage != null) ...[
                SizedBox(height: 10),
                Image.network(correctAnswerImage),
              ],
              SizedBox(height: 10),
              Text(
                "Explanation:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("$explanation"),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: -0.785398, // Rotate text by -45 degrees (in radians)
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color.fromARGB(100, 93, 179, 249),
                  Color.fromARGB(100, 195, 89, 89)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                widget.email,
                style: TextStyle(
                  color: Colors
                      .white, // This color will be overridden by the gradient
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Question Details"),
          content: modalContent,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test Result'),
        ),
        body: _quizResult != null
            ? Stack(
                children: [
                  _buildResultView(),
                  passed // Conditionally show Align widget
                      ? Align(
                          alignment: Alignment.center,
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirection: -1.0,
                            emissionFrequency: 0.05,
                            numberOfParticles: 20,
                            gravity: 0.1,
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                            ],
                          ),
                        )
                      : SizedBox(), // If not passed, keep it hidden
                ],
              )
            : _buildLoadingView(),
        bottomNavigationBar: _quizResult != null
            ? Padding(
                padding: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DentalAccount(
                                accessToken: accessToken,
                              )),
                    );
                  },
                  child: Text('Go to Other Tests'),
                ),
              )
            : null,
      ),
    );
  }
}
