import 'package:flutter/material.dart';
import 'package:tic_tac_game/game_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activePlayer = 'x'; // لمعرفة اللاعب الحالي
  bool gameOver = false; // هل اللعبة انتهت او لا
  int turn =
      0; // عدد الدورات ()عدد دورات اللعبة يعني لو وصلت 9 يعني خلص المربعات
  String result = '';
  Game game = Game();
  bool isSwithch = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: MediaQuery.of(context).orientation == Orientation.portrait
              ? Column(children: [
                  ...firstBloc(),
                  expandedGridView(context),
                  // لاستخراج عناصر الليست
                  ...lastBloc(),
                ])
              : Row(children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...firstBloc(),
                        const SizedBox(
                          height: 20,
                        ),
                        ...lastBloc(),
                      ],
                    ),
                  ),
                  expandedGridView(context),
                ]),
        ));
  }

  List<Widget> firstBloc() {
    return [
      // علشان يناسب الاندرويد والايفون
      SwitchListTile.adaptive(
          title: const Text(
            'Turn on/off two player',
            style: TextStyle(fontSize: 20),
          ),
          value: isSwithch,
          onChanged: (bool newValue) {
            setState(() {
              isSwithch = newValue;
            });
          }),
      const SizedBox(height: 20),
      Text(
        'It\'s $activePlayer turn'.toUpperCase(),
        style: const TextStyle(fontSize: 45),
      ),
    ];
  }

  List<Widget> lastBloc() {
    return [
      Text(
        result,
        style: const TextStyle(fontSize: 45, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        //when pressing the button the value return the default
        onPressed: () {
          setState(() {
            Player.playerX = [];
            Player.playerO = [];
            activePlayer = 'x';
            gameOver = false;
            turn = 0;
            result = '';
          });
        },
        icon: const Icon(Icons.replay),
        label: const Text('Repeat the game'),
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).splashColor),
        ),
      ),
      const SizedBox(height: 40)
    ];
  }

  Expanded expandedGridView(BuildContext context) {
    return Expanded(
        child: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 3,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 1.0,
            children: List.generate(
                9,
                (index) => InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: gameOver ? null : () => _onTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor,
                            borderRadius: BorderRadius.circular(16)),
                        child: Center(
                          child: Text(
                            Player.playerX.contains(index)
                                ? 'X'
                                : Player.playerO.contains(index)
                                    ? 'O'
                                    : '',
                            style: TextStyle(
                                fontSize: 50,
                                color: Player.playerX.contains(index)
                                    ? Colors.blueAccent
                                    : Colors.pinkAccent),
                          ),
                        ),
                      ),
                    ))));
  }

  _onTap(int index) async {
    if (Player.playerX.isEmpty ||
        !Player.playerX.contains(index) && Player.playerO.isEmpty ||
        !Player.playerO.contains(index)) {
      game.playGame(index, activePlayer);
      updateState();

      if (!isSwithch && !gameOver && turn != 9) {
        await game.autoPaly(activePlayer);
        updateState();
      }
    }
  }

  void updateState() {
    setState(() {
      activePlayer = (activePlayer == 'X') ? 'O' : 'X';
      turn++;
      String winnerPlayer = game.checkWinner();

      if (winnerPlayer != '') {
        gameOver = true;
        result = '$winnerPlayer is the winner';
      } else if (!gameOver && turn == 9) {
        result = 'It\'s Draw!';
      }
    });
  }
}
