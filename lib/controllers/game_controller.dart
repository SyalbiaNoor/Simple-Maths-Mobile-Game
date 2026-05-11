import 'dart:async';

import 'package:get/get.dart';

import '../models/question_model.dart';
import '../utils/question_generator.dart';
import '../pages/menu_page.dart';

class GameController extends GetxController {
  late int level;

  Rx<QuestionModel?> currentQuestion = Rx<QuestionModel?>(null);

  // For visualization we keep an assigned owner per cell (which fraction it belongs to)
  RxList<int?> assignedCells = <int?>[].obs;

  // active fraction index selected by the user for tapping/selecting
  RxInt activeFraction = 0.obs;

  // expected counts per fraction (based on proportional assignment)
  List<int> expectedCounts = [];

  RxString resultMessage = ''.obs;

  RxInt rows = 1.obs;
  RxInt cols = 1.obs;

  RxInt score = 0.obs;

  RxInt questionNumber = 1.obs;

  RxInt remainingTime = 300.obs;

  int maxTime = 300;

  Timer? timer;
  Timer? _messageTimer;

  bool timerStarted = false;

  bool isDragging = false;

  int remainingChances = 2;

  double containerWidth = 260;
  double containerHeight = 420;

  // inset padding so side handles don't reach the absolute frame edges
  double handleInset = 12.0;

  RxDouble horizontalHandleX = 0.0.obs;

  RxDouble verticalHandleY = 0.0.obs;

  // drag mode: 'paint' or 'erase'
  String _dragMode = 'paint';
  // visited indices during current drag to avoid repeated toggles
  final Set<int> _dragVisited = {};

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

    // initialize per-fraction selected arrays
    final question = currentQuestion.value;

    if (question != null) {
      for (var item in question.items) {
        item.selectedCells.value = List.generate(totalCells, (_) => false);
      }

      // compute canonical assignment of which cells visually belong to which fraction
      _computeAssignedCells(totalCells);
    } else {
      assignedCells.value = List.generate(totalCells, (_) => null);
    }
  }

  void _computeAssignedCells(int totalCells) {
    final q = currentQuestion.value;
    if (q == null) {
      assignedCells.value = List.generate(totalCells, (_) => null);
      return;
    }

    // compute exact counts per fraction using floor + distribute remainder by fractional part
    List<double> exact = q.items.map((e) => e.value * totalCells).toList();
    List<int> base = exact.map((e) => e.floor()).toList();
    int baseSum = base.fold(0, (a, b) => a + b);
    int remainder = totalCells - baseSum;

    List<MapEntry<int, double>> fractional = [];
    for (int i = 0; i < exact.length; i++) {
      fractional.add(MapEntry(i, exact[i] - base[i]));
    }

    fractional.sort((a, b) => b.value.compareTo(a.value));

    List<int> counts = List.from(base);
    for (int i = 0; i < remainder; i++) {
      counts[fractional[i].key]++;
    }

    // build assignedCells sequentially so each fraction occupies contiguous cells
    List<int?> owners = List<int?>.filled(totalCells, null);
    int cursor = 0;
    for (int fi = 0; fi < counts.length; fi++) {
      for (int j = 0; j < counts[fi]; j++) {
        if (cursor >= totalCells) break;
        owners[cursor++] = fi;
      }
    }

    // leave remaining as null (if any)
    assignedCells.value = owners;

    // store expected counts for later validation
    expectedCounts = counts;
  }

  void updateColumnsFromDrag(double dx) {
    startTimer();

    horizontalHandleX.value += dx;

    final double maxHorizontalRange = (containerWidth - 42) > 0
        ? (containerWidth - 42)
        : 1; // ensure positive divisor

    horizontalHandleX.value = horizontalHandleX.value.clamp(
      0,
      maxHorizontalRange,
    );

    // Map horizontal handle (0..maxHorizontalRange) to columns (1..12)
    cols.value =
        ((horizontalHandleX.value / maxHorizontalRange) * 11).round() + 1;

    updateGrid();
  }

  void updateRowsFromDrag(double dy) {
    startTimer();

    verticalHandleY.value += dy;

    // Account for triangle size: side stack height is containerHeight - 42,
    // so the max top position is that minus the triangle height (42) => containerHeight - 84.
    final double maxVerticalRange = (containerHeight - 84 - handleInset) > 0
        ? (containerHeight - 84 - handleInset)
        : 1; // keep positive divisor (triangle height accounted)

    verticalHandleY.value = verticalHandleY.value.clamp(0, maxVerticalRange);

    // Map vertical handle (0..maxVerticalRange) to rows (1..12)
    rows.value = ((verticalHandleY.value / maxVerticalRange) * 11).round() + 1;

    updateGrid();
  }

  void toggleCell(int index) {
    startTimer();

    final q = currentQuestion.value;
    if (q == null) return;

    int fi = activeFraction.value.clamp(0, q.items.length - 1);

    q.items[fi].selectedCells[index] = !q.items[fi].selectedCells[index];
  }

  void startDragging() {
    isDragging = true;
  }

  void startDraggingAt(int startIndex) {
    isDragging = true;
    _dragVisited.clear();

    final q = currentQuestion.value;
    if (q == null) return;

    int fi = activeFraction.value.clamp(0, q.items.length - 1);

    // determine initial mode based on whether the start cell is already selected by active fraction
    if (q.items[fi].selectedCells.length > startIndex &&
        q.items[fi].selectedCells[startIndex]) {
      _dragMode = 'erase';
    } else {
      _dragMode = 'paint';
    }

    _applyDragAction(startIndex);
  }

  void stopDragging() {
    isDragging = false;
    _dragVisited.clear();
  }

  void _applyDragAction(int index) {
    if (!isDragging) return;

    final q = currentQuestion.value;
    if (q == null) return;

    int fi = activeFraction.value.clamp(0, q.items.length - 1);

    if (_dragVisited.contains(index)) return;
    _dragVisited.add(index);

    if (_dragMode == 'erase') {
      if (q.items[fi].selectedCells.length > index &&
          q.items[fi].selectedCells[index]) {
        q.items[fi].selectedCells[index] = false;
      }
    } else {
      if (q.items[fi].selectedCells.length > index) {
        q.items[fi].selectedCells[index] = true;
      }
    }
  }

  void dragFillCell(int index) {
    // kept for backward compatibility with mouse hover - apply current drag action
    if (!isDragging) return;

    startTimer();
    _applyDragAction(index);
  }

  void clearSelection() {
    final q = currentQuestion.value;
    if (q == null) return;

    for (var item in q.items) {
      for (int i = 0; i < item.selectedCells.length; i++) {
        item.selectedCells[i] = false;
      }
    }
  }

  int get selectedCount {
    final q = currentQuestion.value;
    if (q == null) return 0;

    int total = 0;
    int totalCells = rows.value * cols.value;

    for (int i = 0; i < totalCells; i++) {
      bool any = false;
      for (var item in q.items) {
        if (item.selectedCells.length > i && item.selectedCells[i]) {
          any = true;
          break;
        }
      }
      if (any) total++;
    }

    return total;
  }

  void checkAnswer() {
    final question = currentQuestion.value;

    if (question == null) return;

    int totalCells = rows.value * cols.value;

    // Validate per-fraction selections against expected counts
    if (expectedCounts.length != question.items.length) {
      // fallback to previous total-based validation
      double target = question.totalValue;
      double selectedFraction = selectedCount / totalCells;

      if ((selectedFraction - target).abs() < 0.01) {
        _handleCorrect();
      } else {
        _handleWrong();
      }

      return;
    }

    // Validate per-fraction selection proportions (accepts simplified or unsimplified totals)
    int totalSelected = 0;
    List<int> selectedFor = List.filled(question.items.length, 0);

    for (int i = 0; i < question.items.length; i++) {
      selectedFor[i] = question.items[i].selectedCells.where((s) => s).length;
      totalSelected += selectedFor[i];
    }

    // expected total cells for the fractions (may be < totalCells when totalValue < 1)
    int expectedTotal = (question.totalValue * totalCells).round();

    // allow small rounding tolerance of 1 cell
    if ((totalSelected - expectedTotal).abs() > 1) {
      _handleWrong();
      return;
    }

    if (totalSelected == 0) {
      _handleWrong();
      return;
    }

    // Check proportions per fraction relative to the total selected cells
    bool proportionsMatch = true;

    for (int i = 0; i < question.items.length; i++) {
      final item = question.items[i];
      double expectedProp =
          item.value /
          question.totalValue; // fraction of the whole (normalized)
      double actualProp = selectedFor[i] / totalSelected;

      if ((expectedProp - actualProp).abs() > 0.03) {
        proportionsMatch = false;
        break;
      }
    }

    if (proportionsMatch) {
      _handleCorrect();
    } else {
      _handleWrong();
    }
  }

  void _handleCorrect() {
    resultMessage.value = "Correct!";

    if (level == 1) {
      score.value += 50;
    } else {
      score.value += 100;
    }

    Future.delayed(const Duration(seconds: 1), () {
      nextQuestion();
    });
  }

  void _handleWrong() {
    remainingChances--;

    // Show message depending on remaining chances
    if (remainingChances > 0) {
      final String plural = remainingChances > 1 ? 's' : '';
      resultMessage.value = "Wrong! $remainingChances more chance$plural";

      // cancel any existing message timer
      _messageTimer?.cancel();
      _messageTimer = Timer(const Duration(seconds: 2), () {
        resultMessage.value = '';
      });
    } else {
      // last chance used up
      resultMessage.value = "Wrong!";

      Future.delayed(const Duration(seconds: 2), () {
        nextQuestion();
      });
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
