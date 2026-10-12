// import 'package:flutter/material.dart';
// import 'task1_1.dart' as t11;
// import 'task1_2.dart' as t12;
// import 'task1_3.dart' as t13;
// import 'task1_4.dart' as t14;
// import 'task1_5.dart' as t15;
// import 'task2_1.dart' as t21;
// import 'task2_2.dart' as t22;
// import 'task2_3.dart' as t23;
// import 'task2_4.dart' as t24;
// import 'task2_5.dart' as t25;
// import 'task3_1.dart' as t31;
// import 'task3_2.dart' as t32;
// import 'task3_3.dart' as t33;
// import 'task3_4.dart' as t34;
// import 'task3_5.dart' as t35;
// import 'task4_1.dart' as t41;
// import 'task4_2.dart' as t42;
// import 'task4_3.dart' as t43;
// import 'task4_4.dart' as t44;
// import 'task4_5.dart' as t45;
// import 'task5_1.dart' as t51;
// import 'task5_2.dart' as t52;
// import 'task5_3.dart' as t53;
// import 'task5_4.dart' as t54;
// import 'task5_5.dart' as t55;
// import 'task6_1.dart' as t61;
// import 'task6_2.dart' as t62;
// import 'task6_3.dart' as t63;
// import 'task6_4.dart' as t64;
// import 'task6_5.dart' as t65;

// void main() => runApp(const LauncherApp());

// class Task {
//   final String id;
//   final String title;
//   final Widget Function() build;
//   Task(this.id, this.title, this.build);
// }

// class Category {
//   final String title;
//   final List<Task> tasks;
//   Category(this.title, this.tasks);
// }

// final categories = <Category>[
//   Category('1. Navigator: push and pop', [
//       Task('1.1', 'Two screens with push and pop', t11.buildApp),
//       Task('1.2', 'Three-screen chain', t12.buildApp),
//       Task('1.3', 'Replace, do not stack', t13.buildApp),
//       Task('1.4', 'Back to the start', t14.buildApp),
//       Task('1.5', 'Smart back button', t15.buildApp),
//     ]),
//   Category('2. Named routes', [
//       Task('2.1', 'Route table and pushNamed', t21.buildApp),
//       Task('2.2', 'Menu with four routes', t22.buildApp),
//       Task('2.3', 'Page not found', t23.buildApp),
//       Task('2.4', 'Drawer navigation', t24.buildApp),
//       Task('2.5', 'Log out', t25.buildApp),
//     ]),
//   Category('3. Passing arguments with constructors', [
//       Task('3.1', 'Product list to product details', t31.buildApp),
//       Task('3.2', 'Greeting', t32.buildApp),
//       Task('3.3', 'Contact card', t33.buildApp),
//       Task('3.4', 'Pick a colour (result back)', t34.buildApp),
//       Task('3.5', 'Edit a counter', t35.buildApp),
//     ]),
//   Category('4. Passing arguments with named routes', [
//       Task('4.1', 'ScreenArguments class', t41.buildApp),
//       Task('4.2', 'Send a number', t42.buildApp),
//       Task('4.3', 'User profile', t43.buildApp),
//       Task('4.4', 'onGenerateRoute', t44.buildApp),
//       Task('4.5', 'Result from a named route', t45.buildApp),
//     ]),
//   Category('5. Simple transition animations', [
//       Task('5.1', 'Fade transition', t51.buildApp),
//       Task('5.2', 'Slide from the right', t52.buildApp),
//       Task('5.3', 'Slide from the bottom', t53.buildApp),
//       Task('5.4', 'Scale and fade together', t54.buildApp),
//       Task('5.5', 'Reusable route and global theme', t55.buildApp),
//     ]),
//   Category('6. go_router', [
//       Task('6.1', 'First router: go, push and pop', t61.buildApp),
//       Task('6.2', 'Path parameters', t62.buildApp),
//       Task('6.3', 'Passing an object with extra', t63.buildApp),
//       Task('6.4', 'Named routes and 404 page', t64.buildApp),
//       Task('6.5', 'Transition in go_router', t65.buildApp),
//     ]),
// ];

// class LauncherApp extends StatelessWidget {
//   const LauncherApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Navigation Lab',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: Colors.indigo,
//       ),
//       home: const MenuScreen(),
//     );
//   }
// }

// class MenuScreen extends StatelessWidget {
//   const MenuScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Navigation Lab')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           for (final category in categories) ...[
//             Padding(
//               padding: const EdgeInsets.only(top: 16, bottom: 8),
//               child: Text(
//                 category.title,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//             ),
//             for (final task in category.tasks)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: FilledButton.tonal(
//                   style: FilledButton.styleFrom(
//                     alignment: Alignment.centerLeft,
//                     minimumSize: const Size.fromHeight(48),
//                   ),
//                   onPressed: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => TaskHost(task: task)),
//                   ),
//                   child: Text('${task.id}  ${task.title}'),
//                 ),
//               ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class TaskHost extends StatefulWidget {
//   final Task task;
//   const TaskHost({super.key, required this.task});

//   @override
//   State<TaskHost> createState() => _TaskHostState();
// }

// class _TaskHostState extends State<TaskHost> {
//   late final Widget _app = widget.task.build();

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       body: Column(
//         children: [
//           Material(
//             color: scheme.inverseSurface,
//             child: SafeArea(
//               bottom: false,
//               child: SizedBox(
//                 height: 44,
//                 child: Row(
//                   children: [
//                     TextButton.icon(
//                       style: TextButton.styleFrom(
//                         foregroundColor: scheme.onInverseSurface,
//                       ),
//                       onPressed: () => Navigator.of(context).pop(),
//                       icon: const Icon(Icons.arrow_back),
//                       label: const Text('Menu'),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Task ${widget.task.id} - ${widget.task.title}',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(color: scheme.onInverseSurface),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: MediaQuery.removePadding(
//               context: context,
//               removeTop: true,
//               child: _app,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'task1_2.dart' as t12;
import 'task1_3.dart' as t13;
import 'task2_2.dart' as t22;
import 'task2_3.dart' as t23;
import 'task3_2.dart' as t32;
import 'task3_3.dart' as t33;
import 'task4_2.dart' as t42;
import 'task4_3.dart' as t43;
import 'task5_2.dart' as t52;
import 'task5_3.dart' as t53;
import 'task6_2.dart' as t62;
import 'task6_3.dart' as t63;

void main() => runApp(const LauncherApp());

class Task {
  final String id;
  final String title;
  final Widget Function() build;
  Task(this.id, this.title, this.build);
}

class Category {
  final String title;
  final List<Task> tasks;
  Category(this.title, this.tasks);
}

final categories = <Category>[
  Category('1. Navigator: push and pop', [
      Task('1.2', 'Three-screen chain', t12.buildApp),
      Task('1.3', 'Replace, do not stack', t13.buildApp),
    ]),
  Category('2. Named routes', [
      Task('2.2', 'Menu with four routes', t22.buildApp),
      Task('2.3', 'Page not found', t23.buildApp),
    ]),
  Category('3. Passing arguments with constructors', [
      Task('3.2', 'Greeting', t32.buildApp),
      Task('3.3', 'Contact card', t33.buildApp),
    ]),
  Category('4. Passing arguments with named routes', [
      Task('4.2', 'Send a number', t42.buildApp),
      Task('4.3', 'User profile', t43.buildApp),
    ]),
  Category('5. Simple transition animations', [
      Task('5.2', 'Slide from the right', t52.buildApp),
      Task('5.3', 'Slide from the bottom', t53.buildApp),
    ]),
  Category('6. go_router', [
      Task('6.2', 'Path parameters', t62.buildApp),
      Task('6.3', 'Passing an object with extra', t63.buildApp),
    ]),
];

class LauncherApp extends StatelessWidget {
  const LauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Lab')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                category.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            for (final task in category.tasks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaskHost(task: task)),
                  ),
                  child: Text('${task.id}  ${task.title}'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class TaskHost extends StatefulWidget {
  final Task task;
  const TaskHost({super.key, required this.task});

  @override
  State<TaskHost> createState() => _TaskHostState();
}

class _TaskHostState extends State<TaskHost> {
  late final Widget _app = widget.task.build();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          Material(
            color: scheme.inverseSurface,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onInverseSurface,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Menu'),
                    ),
                    Expanded(
                      child: Text(
                        'Task ${widget.task.id} - ${widget.task.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: scheme.onInverseSurface),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: _app,
            ),
          ),
        ],
      ),
    );
  }
}