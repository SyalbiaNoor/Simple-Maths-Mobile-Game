import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../models/question_model.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GlobalKey _gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final GameController controller = Get.put(GameController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      body: SafeArea(
        child: Obx(() {
          final question = controller.currentQuestion.value;

          if (question == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // =========================
                // TOP BAR
                // =========================
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF241B4B),
                          size: 26,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Text(
                      "Level ${controller.level}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF241B4B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // =========================
                // PROGRESS BAR
                // =========================
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: controller.remainingTime.value / controller.maxTime,
                    minHeight: 12,
                    backgroundColor: Colors.deepPurple.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                  ),
                ),

                const SizedBox(height: 16),

                // =========================
                // QUESTION + SCORE
                // =========================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoCard(
                      icon: Icons.help_outline_rounded,
                      iconColor: Colors.purple,
                      text: "Q ${controller.questionNumber.value}/5",
                    ),

                    _infoCard(
                      icon: Icons.star_rounded,
                      iconColor: Colors.amber,
                      text: "${controller.score.value}",
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =========================
                // QUESTION TEXT
                // =========================
                Column(
                  children: [
                    _buildQuestionWidget(controller, question),

                    const SizedBox(height: 4),

                    SizedBox(
                      height: 34,
                      child: Center(
                        child: Text(
                          controller.resultMessage.value,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color:
                                controller.resultMessage.value.contains(
                                  "Correct",
                                )
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Fraction chips removed — fractions are selectable by tapping the fraction itself above

                // =========================
                // TOP HANDLE
                // =========================
                SizedBox(
                  width: controller.containerWidth,
                  child: Stack(
                    children: [
                      Container(height: 44),

                      Positioned(
                        left: controller.horizontalHandleX.value
                            .clamp(
                              0,
                              (controller.containerWidth - 42) > 0
                                  ? controller.containerWidth - 42
                                  : 0,
                            )
                            .toDouble(),
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            controller.updateColumnsFromDrag(details.delta.dx);
                          },
                          child: _triangleButton(
                            direction: TriangleDirection.down,
                            value: controller.cols.value.toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================
                // GRID + SIDE HANDLES
                // =========================
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 44,
                        height:
                            controller.containerHeight -
                            42 -
                            controller.handleInset,
                        child: Stack(
                          children: [
                            Positioned(
                              top: controller.verticalHandleY.value
                                  .clamp(
                                    0,
                                    (controller.containerHeight -
                                                84 -
                                                controller.handleInset) >
                                            0
                                        ? controller.containerHeight -
                                              84 -
                                              controller.handleInset
                                        : 0,
                                  )
                                  .toDouble(),
                              child: GestureDetector(
                                onVerticalDragUpdate: (details) {
                                  controller.updateRowsFromDrag(
                                    details.delta.dy,
                                  );
                                },
                                child: _triangleButton(
                                  direction: TriangleDirection.right,
                                  value: controller.rows.value.toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onPanStart: (details) {
                          // determine starting cell and initialize drag mode
                          // use the grid's RenderBox to get coordinates relative to the grid
                          try {
                            final box =
                                _gridKey.currentContext?.findRenderObject()
                                    as RenderBox?;
                            final local = box != null
                                ? box.globalToLocal(details.globalPosition)
                                : details.localPosition;

                            final double dx = local.dx - 5;
                            final double dy = local.dy - 5;

                            if (dx < 0 || dy < 0) {
                              controller.startDragging();
                            } else {
                              final int cols = controller.cols.value;
                              final int rows = controller.rows.value;

                              if (cols > 0 && rows > 0) {
                                final double innerW = box != null
                                    ? ((box.size.width - 10) > 0
                                          ? box.size.width - 10
                                          : box.size.width)
                                    : ((controller.containerWidth - 10) > 0
                                          ? controller.containerWidth - 10
                                          : controller.containerWidth);

                                final double innerH = box != null
                                    ? ((box.size.height - 10) > 0
                                          ? box.size.height - 10
                                          : box.size.height)
                                    : ((controller.containerHeight - 10) > 0
                                          ? controller.containerHeight - 10
                                          : controller.containerHeight);

                                final double cellW = innerW / cols;
                                final double cellH = innerH / rows;

                                int col = (dx / cellW).floor();
                                int row = (dy / cellH).floor();

                                if (col < 0) col = 0;
                                if (col >= cols) col = cols - 1;
                                if (row < 0) row = 0;
                                if (row >= rows) row = rows - 1;

                                int index = row * cols + col;
                                controller.startDraggingAt(index);
                              } else {
                                controller.startDragging();
                              }
                            }
                          } catch (e) {
                            controller.startDragging();
                          }
                        },
                        onPanUpdate: (details) {
                          // convert drag position into grid cell index and fill it
                          try {
                            final box =
                                _gridKey.currentContext?.findRenderObject()
                                    as RenderBox?;
                            final local = box != null
                                ? box.globalToLocal(details.globalPosition)
                                : details.localPosition;

                            // account for container padding of 5 on all sides
                            final double dx = local.dx - 5;
                            final double dy = local.dy - 5;

                            if (dx < 0 || dy < 0) return;

                            final int cols = controller.cols.value;
                            final int rows = controller.rows.value;

                            if (cols <= 0 || rows <= 0) return;

                            final double innerW = box != null
                                ? ((box.size.width - 10) > 0
                                      ? box.size.width - 10
                                      : box.size.width)
                                : ((controller.containerWidth - 10) > 0
                                      ? controller.containerWidth - 10
                                      : controller.containerWidth);

                            final double innerH = box != null
                                ? ((box.size.height - 10) > 0
                                      ? box.size.height - 10
                                      : box.size.height)
                                : ((controller.containerHeight - 10) > 0
                                      ? controller.containerHeight - 10
                                      : controller.containerHeight);

                            final double cellW = innerW / cols;
                            final double cellH = innerH / rows;

                            int col = (dx / cellW).floor();
                            int row = (dy / cellH).floor();

                            if (col < 0) col = 0;
                            if (col >= cols) col = cols - 1;
                            if (row < 0) row = 0;
                            if (row >= rows) row = rows - 1;

                            int index = row * cols + col;

                            controller.dragFillCell(index);
                          } catch (e) {
                            // ignore conversion errors
                          }
                        },
                        onPanEnd: (_) {
                          controller.stopDragging();
                        },
                        child: Container(
                          key: _gridKey,
                          width: controller.containerWidth,
                          height: controller.containerHeight,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: List.generate(controller.rows.value, (
                              row,
                            ) {
                              return Expanded(
                                child: Row(
                                  children: List.generate(controller.cols.value, (
                                    col,
                                  ) {
                                    int index =
                                        row * controller.cols.value + col;

                                    return Expanded(
                                      child: MouseRegion(
                                        onEnter: (_) {
                                          controller.dragFillCell(index);
                                        },
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.toggleCell(index);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 120,
                                            ),
                                            margin: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: () {
                                                int selectingIndex = -1;

                                                for (
                                                  int si = 0;
                                                  si < question.items.length;
                                                  si++
                                                ) {
                                                  final it = question.items[si];
                                                  if (it.selectedCells.length >
                                                          index &&
                                                      it.selectedCells[index]) {
                                                    selectingIndex = si;
                                                    break;
                                                  }
                                                }

                                                if (selectingIndex != -1) {
                                                  return question
                                                      .items[selectingIndex]
                                                      .color
                                                      .withOpacity(0.95);
                                                }

                                                // initially empty white grid
                                                return Colors.white;
                                              }(),
                                              border: Border.all(
                                                color: const Color(0xFF9575CD),
                                                width: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 44,
                        height:
                            controller.containerHeight -
                            42 -
                            controller.handleInset,
                        child: Stack(
                          children: [
                            Positioned(
                              top: controller.verticalHandleY.value
                                  .clamp(
                                    0,
                                    (controller.containerHeight -
                                                84 -
                                                controller.handleInset) >
                                            0
                                        ? controller.containerHeight -
                                              84 -
                                              controller.handleInset
                                        : 0,
                                  )
                                  .toDouble(),
                              child: GestureDetector(
                                onVerticalDragUpdate: (details) {
                                  controller.updateRowsFromDrag(
                                    details.delta.dy,
                                  );
                                },
                                child: _triangleButton(
                                  direction: TriangleDirection.left,
                                  value: controller.rows.value.toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================
                // BOTTOM HANDLE
                // =========================
                SizedBox(
                  width: controller.containerWidth,
                  child: Stack(
                    children: [
                      Container(height: 44),

                      Positioned(
                        left: controller.horizontalHandleX.value
                            .clamp(
                              0,
                              (controller.containerWidth - 42) > 0
                                  ? controller.containerWidth - 42
                                  : 0,
                            )
                            .toDouble(),
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            controller.updateColumnsFromDrag(details.delta.dx);
                          },
                          child: _triangleButton(
                            direction: TriangleDirection.up,
                            value: controller.cols.value.toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // =========================
                // BUTTONS
                // =========================
                Row(
                  children: [
                    Expanded(
                      child: _gameButton(
                        text: "Check",
                        color: const Color(0xFF8B5CF6),
                        icon: Icons.check_rounded,
                        onTap: () {
                          controller.checkAnswer();
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _gameButton(
                        text: "Clear",
                        color: const Color(0xFFF5A623),
                        icon: Icons.refresh_rounded,
                        onTap: () {
                          controller.clearSelection();
                        },
                        // slightly darken the foreground (text & icon) while keeping the same tone
                        iconColor: _darken(const Color(0xFFF5A623), 0.22),
                        textColor: _darken(const Color(0xFFF5A623), 0.22),
                        // make avatar slightly translucent so the darker icon contrasts
                        avatarColor: const Color(0xFFF5A623).withOpacity(0.94),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _gameButton(
                        text: "Skip",
                        color: const Color(0xFF4DA6FF),
                        icon: Icons.fast_forward_rounded,
                        onTap: () {
                          controller.skipQuestion();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // =========================
  // FRACTION DISPLAY
  // =========================

  static Widget _buildQuestionWidget(
    GameController controller,
    QuestionModel question,
  ) {
    bool showAnswer =
        controller.resultMessage.value == "Correct!" ||
        controller.remainingChances == 0;

    List<Widget> widgets = [];

    for (int i = 0; i < question.items.length; i++) {
      final item = question.items[i];

      widgets.add(
        GestureDetector(
          onTap: () {
            controller.activeFraction.value = i;
          },
          child: _fractionWidget(
            item.numerator.toString(),
            item.denominator.toString(),
            item.color,
            active: controller.activeFraction.value == i,
          ),
        ),
      );

      if (i != question.items.length - 1) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "+",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF241B4B),
              ),
            ),
          ),
        );
      }
    }

    if (showAnswer) {
      int numeratorSum = 0;
      int commonDenominator = 1;

      for (var item in question.items) {
        commonDenominator *= item.denominator;
      }

      for (var item in question.items) {
        numeratorSum +=
            item.numerator * (commonDenominator ~/ item.denominator);
      }

      int gcdValue = _gcd(numeratorSum, commonDenominator);

      int finalNumerator = numeratorSum ~/ gcdValue;

      int finalDenominator = commonDenominator ~/ gcdValue;

      widgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "=",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF241B4B),
            ),
          ),
        ),
      );

      widgets.add(
        _fractionWidget(
          finalNumerator.toString(),
          finalDenominator.toString(),
          const Color(0xFF241B4B),
        ),
      );
    }

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: widgets,
        ),
        const SizedBox(height: 8),
        // No legend: the fraction is shown directly above and is tappable
      ],
    );
  }

  static Widget _fractionWidget(
    String numerator,
    String denominator,
    Color color, {
    bool active = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: active ? Border.all(color: color, width: 2) : null,
        color: active ? color.withOpacity(0.06) : Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            numerator,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),

          Container(
            width: 36,
            height: 3,
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Text(
            denominator,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }

    return a;
  }

  static Widget _triangleButton({
    required TriangleDirection direction,
    required String value,
  }) {
    IconData icon;

    switch (direction) {
      case TriangleDirection.up:
        icon = Icons.keyboard_arrow_up;
        break;

      case TriangleDirection.down:
        icon = Icons.keyboard_arrow_down;
        break;

      case TriangleDirection.left:
        icon = Icons.keyboard_arrow_left;
        break;

      case TriangleDirection.right:
        icon = Icons.keyboard_arrow_right;
        break;
    }

    return ClipPath(
      clipper: TriangleClipper(direction),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(color: Color(0xFF8B5CF6)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.22), size: 28),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),

          const SizedBox(width: 6),

          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF241B4B),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _gameButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Color? avatarColor,
  }) {
    final Color usedAvatar = avatarColor ?? color;
    final Color usedIcon = iconColor ?? Colors.white;
    final Color usedText = textColor ?? color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: usedAvatar,
              child: Icon(icon, color: usedIcon, size: 15),
            ),

            const SizedBox(width: 6),

            Text(
              text,
              style: TextStyle(
                color: usedText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

enum TriangleDirection { up, down, left, right }

class TriangleClipper extends CustomClipper<Path> {
  final TriangleDirection direction;

  TriangleClipper(this.direction);

  @override
  Path getClip(Size size) {
    Path path = Path();

    switch (direction) {
      case TriangleDirection.up:
        path.moveTo(size.width / 2, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;

      case TriangleDirection.down:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width / 2, size.height);
        break;

      case TriangleDirection.left:
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;

      case TriangleDirection.right:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
    }

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
