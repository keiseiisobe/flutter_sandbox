import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerWidget, Ref, StateProvider, WidgetRef;
import 'package:provider/provider.dart' show ChangeNotifierProvider, Consumer;

class InheritedCounter extends InheritedWidget {
  const InheritedCounter({
    super.key,
    required super.child,
    required this.counter,
    required this.increment,
    required this.reset,
  });

  final int counter;
  final VoidCallback increment;
  final VoidCallback reset;

  static InheritedCounter of(BuildContext context) {
    final InheritedCounter? result = context
        .dependOnInheritedWidgetOfExactType<InheritedCounter>();
    assert(result != null, 'No InheritedCounter found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedCounter oldWidget) {
    return counter != oldWidget.counter;
  }
}

class CounterNotifier extends ChangeNotifier {
  int value = 0;

  void increment() {
    value++;
    notifyListeners();
  }

  void reset() {
    value = 0;
    notifyListeners();
  }
}

final StateProvider<int> riverpodCounterProvider = StateProvider<int>(
  (Ref ref) => 0,
);

class StateManagementPage extends StatelessWidget {
  const StateManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StateManagementPage')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulate behavior differences of each state management style.',
            ),
            SizedBox(height: 12),
            _InheritedWidgetSimulation(),
            SizedBox(height: 12),
            _ProviderSimulation(),
            SizedBox(height: 12),
            _RiverpodSimulation(),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _InheritedWidgetSimulation extends StatefulWidget {
  const _InheritedWidgetSimulation();

  @override
  State<_InheritedWidgetSimulation> createState() =>
      _InheritedWidgetSimulationState();
}

class _InheritedWidgetSimulationState
    extends State<_InheritedWidgetSimulation> {
  int _counter = 0;

  void _increment() => setState(() => _counter++);

  void _reset() => setState(() => _counter = 0);

  @override
  Widget build(BuildContext context) {
    return InheritedCounter(
      counter: _counter,
      increment: _increment,
      reset: _reset,
      child: const _SectionCard(
        title: 'InheritedWidget',
        description:
            'Base Flutter mechanism. You manually create and expose dependencies.',
        child: _InheritedCounterConsumer(),
      ),
    );
  }
}

class _InheritedCounterConsumer extends StatelessWidget {
  const _InheritedCounterConsumer();

  @override
  Widget build(BuildContext context) {
    final InheritedCounter data = InheritedCounter.of(context);
    return _CounterControls(
      value: data.counter,
      onIncrement: data.increment,
      onReset: data.reset,
    );
  }
}

class _ProviderSimulation extends StatelessWidget {
  const _ProviderSimulation();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CounterNotifier(),
      child: _SectionCard(
        title: 'Provider',
        description:
            'Built on InheritedWidget. Reduces boilerplate with watch/read APIs.',
        child: Consumer<CounterNotifier>(
          builder: (_, CounterNotifier notifier, __) {
            return _CounterControls(
              value: notifier.value,
              onIncrement: notifier.increment,
              onReset: notifier.reset,
            );
          },
        ),
      ),
    );
  }
}

class _RiverpodSimulation extends ConsumerWidget {
  const _RiverpodSimulation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int value = ref.watch(riverpodCounterProvider);
    return _SectionCard(
      title: 'Riverpod',
      description:
          'No BuildContext lookup required. Better testability and provider composition.',
      child: _CounterControls(
        value: value,
        onIncrement: () => ref.read(riverpodCounterProvider.notifier).state++,
        onReset: () => ref.read(riverpodCounterProvider.notifier).state = 0,
      ),
    );
  }
}

class _CounterControls extends StatelessWidget {
  const _CounterControls({
    required this.value,
    required this.onIncrement,
    required this.onReset,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Count: $value',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ElevatedButton(onPressed: onIncrement, child: const Text('+1')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onReset, child: const Text('Reset')),
          ],
        ),
      ),
    );
  }
}
