import 'dart:async';

import 'package:get/get.dart';

import '../models/question_model.dart';
import '../utils/question_generator.dart';
import '../pages/menu_page.dart';

class GameController extends GetxController {
  late int level;

  Rx<QuestionModel?> currentQuestion = Rx<QuestionModel?>(null);

  RxList<bool> selectedCells = <bool>[].obs;

  RxString resultMessage = ''.obs;

  RxInt rows = 1.obs;
  RxInt cols = 1.obs;

  RxInt score = 0.obs;

  RxInt questionNumber = 1.obs;

  RxInt remainingTime = 300.obs;

  int maxTime = 300;

  Timer? timer;

  bool timerStarted = false;

  bool isDragging = false;

  int remainingChances = 2;

  double containerWidth = 260;
  double containerHeight = 420;

  RxDouble horizontalHandleX = 0.0.obs;

  RxDouble verticalHandleY = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    level = Get.arguments;

    if (level == 1) {
      remainingTime.value = 300;
      maxTime = 300;
    } else {
      remainingTime.value = 420;
      maxTime = 420;
    }

    generateQuestion();
  }

  void startTimer() {
    if (timerStarted) return;

    timerStarted = true;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        endGame("Time's Up!");
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    timerStarted = false;
  }

  void generateQuestion() {
    pauseTimer();

    currentQuestion.value = QuestionGenerator.generate(level);

    rows.value = 1;
    cols.value = 1;

    remainingChances = 2;

    horizontalHandleX.value = 0;
    verticalHandleY.value = 0;

    updateGrid();

    resultMessage.value = '';
  }

  void updateGrid() {
    int totalCells = rows.value * cols.value;

    selectedCells.value = List.generate(totalCells, (_) => false);
  }

  void updateColumnsFromDrag(double dx) {
    startTimer();

    horizontalHandleX.value += dx;

    horizontalHandleX.value = horizontalHandleX.value.clamp(
      0,
      containerWidth - 40,
    );

    cols.value =
        ((horizontalHandleX.value / (containerWidth - 40)) * 9).round() + 1;

    updateGrid();
  }

  void updateRowsFromDrag(double dy) {
    startTimer();

    verticalHandleY.value += dy;

    verticalHandleY.value = verticalHandleY.value.clamp(
      0,
      containerHeight - 40,
    );

    rows.value =
        ((verticalHandleY.value / (containerHeight - 40)) * 9).round() + 1;

    updateGrid();
  }

  void toggleCell(int index) {
    startTimer();

    selectedCells[index] = !selectedCells[index];
  }

  void startDragging() {
    isDragging = true;
  }

  void stopDragging() {
    isDragging = false;
  }

  void dragFillCell(int index) {
    if (!isDragging) return;

    startTimer();

    selectedCells[index] = true;
  }

  void clearSelection() {
    for (int i = 0; i < selectedCells.length; i++) {
      selectedCells[i] = false;
    }
  }

  int get selectedCount {
    return selectedCells.where((cell) => cell).length;
  }

  void checkAnswer() {
    final question = currentQuestion.value;

    if (question == null) return;

    int totalCells = rows.value * cols.value;

    double target = question.totalValue;

    double selectedFraction = selectedCount / totalCells;

    if ((selectedFraction - target).abs() < 0.01) {
      resultMessage.value = "Correct!";

      if (level == 1) {
        score.value += 50;
      } else {
        score.value += 100;
      }

      Future.delayed(const Duration(seconds: 1), () {
        nextQuestion();
      });
    } else {
      remainingChances--;

      if (remainingChances > 0) {
        resultMessage.value = "Wrong! ${remainingChances} chance left";
      } else {
        resultMessage.value = "Wrong!";

        Future.delayed(const Duration(seconds: 2), () {
          nextQuestion();
        });
      }
    }
  }

  void skipQuestion() {
    nextQuestion();
  }

  void nextQuestion() {
    if (questionNumber.value >= 5) {
      endGame("Game Finished!");
      return;
    }

    questionNumber.value++;

    generateQuestion();
  }

  void endGame(String title) {
    pauseTimer();

    Get.defaultDialog(
      title: title,
      middleText: "Final Score: ${score.value}",
      textConfirm: "Back to Menu",
      onConfirm: () {
        Get.offAll(() => const MenuPage());
      },
    );
  }

  @override
  void onClose() {
    pauseTimer();
    super.onClose();
  }
}
