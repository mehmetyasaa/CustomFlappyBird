import 'dart:async';
import 'dart:math'; // Import for random number generation
import 'package:flappybird/barriers.dart';
import 'package:flappybird/bird.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double birdYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdYaxis;
  bool gameHasStarted = false;
  bool gameOver = false;

  static double barrierXone = 1;
  double barrierXtwo = barrierXone + 1.5;
  double barrierHeight1 = 150.0;
  double barrierHeight2 = 100.0;
  double barrierHeight3 = 200.0;
  double birdWeight = 3;

  bool showGrowWarning = false;
  Random random = Random();
  Timer? barrierUpdateTimer;
  Timer? birdWeightTimer;

  void jump() {
    if (gameOver) return;

    setState(() {
      time = 0;
      initialHeight = birdYaxis;
    });
  }

  int mostScore = 0;
  int score = 0;
  void scoreVoid() {
    setState(() {
      score += 1;
    });
  }

  void startGame() {
    gameHasStarted = true;
    barrierUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      updateBarrierHeights();
    });

    birdWeightTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setBirdWeight();
    });

    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      time += 0.05;
      height = -4.9 * time * time + birdWeight * time;

      setState(() {
        birdYaxis = initialHeight - height;
      });

      setState(() {
        if (barrierXone < -2) {
          barrierXone += 3.5;
          scoreVoid();
        } else {
          barrierXone -= 0.05;
        }

        if (barrierXtwo < -2) {
          barrierXtwo += 3.5;
        } else {
          barrierXtwo -= 0.05;
        }

        // Çarpışma kontrolü
        if (birdYaxis > 1 || birdYaxis < -1 || checkCollision()) {
          timer.cancel();
          barrierUpdateTimer?.cancel(); // Cancel the barrier update timer
          birdWeightTimer?.cancel(); // Cancel the bird weight timer
          setState(() {
            gameOver = true;
            showGrowWarning = false; // Oyun bittiğinde uyarıyı gizle
          });
        }
      });
    });
  }

  void updateBarrierHeights() {
    setState(() {
      barrierHeight1 = random.nextInt(150) + 100;
      barrierHeight2 = random.nextInt(150) + 100;
      barrierHeight3 = random.nextInt(150) + 100;
    });
  }

  void setBirdWeight() {
    int randomSeconds = random.nextInt(10) + 10;
    birdWeightTimer?.cancel();
    Timer(Duration(seconds: randomSeconds - 2), () {
      if (!gameOver) {
        setState(() {
          showGrowWarning = true;
        });
      }
    });
    birdWeightTimer = Timer(Duration(seconds: randomSeconds), () {
      if (!gameOver) {
        setState(() {
          birdWeight = 1.9;
          showGrowWarning = false;
        });
        resetBirdWeight();
      }
    });
  }

  void resetBirdWeight() {
    int randomSeconds =
        random.nextInt(10) + 10; 
    birdWeightTimer?.cancel();
    Timer(Duration(seconds: randomSeconds - 2), () {
      if (!gameOver) {
        setState(() {
          showGrowWarning = true;
        });
      }
    });
    birdWeightTimer = Timer(Duration(seconds: randomSeconds), () {
      if (!gameOver) {
        setState(() {
          birdWeight = 3;
          showGrowWarning = false;
        });
        setBirdWeight();
      }
    });
  }

  bool checkCollision() {
    double birdHeight = 0.1;

    // Bariyer 1 alt
    if ((barrierXone <= 0.1 && barrierXone >= -0.1) &&
        (birdYaxis + birdHeight >=
            1 - barrierHeight1 / MediaQuery.of(context).size.height * 2)) {
      return true;
    }

    // Bariyer 1 üst
    if ((barrierXone <= 0.1 && barrierXone >= -0.1) &&
        (birdYaxis - birdHeight <=
            -1 + barrierHeight1 / MediaQuery.of(context).size.height * 2)) {
      return true;
    }

    // Bariyer 2 (alt)
    if ((barrierXtwo <= 0.1 && barrierXtwo >= -0.1) &&
        (birdYaxis + birdHeight >=
            1 - barrierHeight2 / MediaQuery.of(context).size.height * 2)) {
      return true;
    }

    // Bariyer 2 (üst)
    if ((barrierXtwo <= 0.1 && barrierXtwo >= -0.1) &&
        (birdYaxis - birdHeight <=
            -1 + barrierHeight3 / MediaQuery.of(context).size.height * 2)) {
      return true;
    }

    return false;
  }

  void resetGame() {
    setState(() {
      birdWeight = 3;
      birdYaxis = 0;
      gameHasStarted = false;
      gameOver = false;
      time = 0;
      initialHeight = birdYaxis;
      barrierXone = 1;
      barrierXtwo = barrierXone + 1.5;
      barrierHeight1 = 150.0;
      barrierHeight2 = 100.0;
      barrierHeight3 = 200.0;
      score = 0;
      showGrowWarning = false;
      barrierUpdateTimer?.cancel();
      birdWeightTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameOver) {
          resetGame();
        } else if (gameHasStarted) {
          scoreVoid();
          jump();
        } else {
          startGame();
        }
        setState(() {
          if (mostScore < score) mostScore = score;
        });
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  AnimatedContainer(
                    alignment: Alignment(0, birdYaxis),
                    duration: const Duration(milliseconds: 0),
                    color: Colors.blue,
                    child: MyBird(
                      birdWeight: birdWeight,
                    ),
                  ),
                  Container(
                    alignment: const Alignment(0, -0.3),
                    child: gameHasStarted
                        ? const Text(" ")
                        : const Text(
                            "T A P  T O  P L A Y",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXone, 1.1),
                    duration: const Duration(milliseconds: 0),
                    child: MyBarrier(size: barrierHeight1),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXone, -1.1),
                    duration: const Duration(milliseconds: 0),
                    child: MyBarrier(size: barrierHeight1),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXtwo, 1.1),
                    duration: const Duration(milliseconds: 0),
                    child: MyBarrier(size: barrierHeight2),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierXtwo, -1.1),
                    duration: const Duration(milliseconds: 0),
                    child: MyBarrier(size: barrierHeight3),
                  ),
                  // Çarpışma alanlarını göster
                  if (gameOver)
                    Container(
                      alignment: const Alignment(0, -0.6),
                      child: const Text(
                        "G A M E  O V E R",
                        style: TextStyle(fontSize: 30, color: Colors.red),
                      ),
                    ),
                  if (showGrowWarning)
                    Container(
                      alignment: const Alignment(0, -0.5),
                      child: Image.asset(
                        'lib/images/warning.gif',
                        width: MediaQuery.of(context).size.height * 0.2,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              height: 15,
              color: Colors.green,
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Score",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 35),
                              ),
                              Text(
                                "$score",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 35),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Most Score",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 35),
                            ),
                            Text(
                              "$mostScore",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 35),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
