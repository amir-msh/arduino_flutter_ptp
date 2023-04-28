import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ptp/provider/led_provider.dart';
import 'package:flutter_ptp/ui/components/spinner_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    context.read<LedProvider>().loadLatestState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ledProvider = context.watch<LedProvider>();
    final ledState = ledProvider.ledState;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ad hoc connection'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: ledState
                      ? [
                          Colors.lightBlue[50]!,
                          Colors.lightBlue[500]!,
                        ]
                      : [
                          Colors.blue[900]!,
                          Colors.indigo,
                        ],
                  radius: 1.25,
                  center: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.66),
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              reverseDuration: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                return SpinnerTransition(
                  animation: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                );
              },
              child: ledProvider.networkState == NetworkState.syncFail
                  ? const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 39,
                    )
                  : const SizedBox(),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: ledProvider.networkState == NetworkState.syncing
                    ? null
                    : ledProvider.toggleLedState,
                highlightColor: ledState
                    ? Colors.white10
                    : const Color.fromARGB(60, 33, 48, 133),
                splashColor: ledState
                    ? Colors.white30
                    : const Color.fromARGB(66, 12, 24, 106),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: ledState ? Colors.white30 : Colors.black12,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          reverseDuration: const Duration(milliseconds: 1250),
                          duration: const Duration(milliseconds: 1250),
                          child: SvgPicture.asset(
                            "assets/icons/led_${ledState ? 'on' : 'off'}.svg",
                            height: 125,
                            key: ValueKey(ledState),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: ledState
                                    ? const Color.fromARGB(255, 48, 15, 113)
                                    : Colors.lightBlue[200],
                              ),
                          child: AnimatedSwitcher(
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            reverseDuration: const Duration(milliseconds: 666),
                            duration: const Duration(milliseconds: 666),
                            child:
                                Text("The light is ${ledState ? 'on' : 'off'}"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoSwitch(
                          value: ledState,
                          onChanged:
                              ledProvider.networkState == NetworkState.syncing
                                  ? null
                                  : ledProvider.setLedState,
                          trackColor: Colors.grey,
                          activeColor: Colors.blue[900],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              reverseDuration: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: ledProvider.networkState != NetworkState.syncing
                  ? const SizedBox()
                  : const ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(6.66),
                      ),
                      child: LinearProgressIndicator(
                        minHeight: 9,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: ledState
                      ? const Color.fromARGB(255, 11, 58, 120)
                      : Colors.blue[100],
                ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 27),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Written by :\nAmir Mohammad Mashayekhi',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
