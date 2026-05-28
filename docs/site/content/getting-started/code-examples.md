---
title: Code Examples
description: Common patterns and code examples for building apps with Skribble's hand-drawn design system.
---

# Code Examples

This page provides code examples for common patterns when building apps with Skribble. Each example shows the Skribble way of implementing typical Flutter UI patterns.

## Basic App Structure

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WiredMaterialApp(
      title: 'My Skribble App',
      theme: WiredThemeData(
        borderColor: Color(0xFF1A2B3C),
        textColor: Colors.black87,
        fillColor: Colors.white,
        strokeWidth: 2.0,
        roughness: 1.0,
        fontFamily: 'Skribble',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    return WiredScaffold(
      appBar: WiredAppBar(
        title: Text('My App'),
        actions: [
          WiredIconButton(
            icon: Icons.search,
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(selectedIndex.value),
      bottomNavigationBar: WiredBottomNav(
        currentIndex: selectedIndex.value,
        onTap: (index) => selectedIndex.value = index,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return HomeTab();
      case 1:
        return SearchTab();
      case 2:
        return ProfileTab();
      default:
        return HomeTab();
    }
  }
}
```

## Forms with Validation

```dart
class LoginForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return WiredCard(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Login',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              WiredInput(
                controller: emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                semanticLabel: 'Email address',
              ),
              SizedBox(height: 16),
              WiredInput(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                obscureText: true,
                semanticLabel: 'Password',
              ),
              SizedBox(height: 24),
              WiredElevatedButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          isLoading.value = true;
                          // Simulate network request
                          await Future.delayed(Duration(seconds: 2));
                          isLoading.value = false;
                        }
                      },
                child: isLoading.value
                    ? WiredLoadingIndicator(size: 20, color: Colors.white)
                    : Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Lists with Swipe Actions

```dart
class TaskList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final tasks = useState([
      Task(title: 'Buy groceries', completed: false),
      Task(title: 'Walk the dog', completed: true),
      Task(title: 'Write code', completed: false),
    ]);

    return WiredScaffold(
      appBar: WiredAppBar(title: Text('Tasks')),
      body: ListView.builder(
        itemCount: tasks.value.length,
        itemBuilder: (context, index) {
          final task = tasks.value[index];
          return WiredDismissible(
            key: ValueKey(task.title),
            onDismissed: (direction) {
              final newList = List<Task>.from(tasks.value);
              newList.removeAt(index);
              tasks.value = newList;
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: WiredListTile(
              leading: WiredCheckbox(
                value: task.completed,
                onChanged: (value) {
                  final newList = List<Task>.from(tasks.value);
                  newList[index] = Task(
                    title: task.title,
                    completed: value ?? false,
                  );
                  tasks.value = newList;
                },
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: WiredFab(
        onPressed: () {
          // Add new task
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Settings Screen

```dart
class SettingsScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final notificationsEnabled = useState(true);
    final darkModeEnabled = useState(false);
    final selectedLanguage = useState('English');

    return WiredScaffold(
      appBar: WiredAppBar(title: Text('Settings')),
      body: ListView(
        children: [
          WiredListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: WiredSwitch(
              value: notificationsEnabled.value,
              onChanged: (value) => notificationsEnabled.value = value,
            ),
          ),
          WiredDivider(),
          WiredListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark Mode'),
            trailing: WiredSwitch(
              value: darkModeEnabled.value,
              onChanged: (value) => darkModeEnabled.value = value,
            ),
          ),
          WiredDivider(),
          WiredExpansionTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text(selectedLanguage.value),
            children: [
              WiredRadioListTile(
                value: 'English',
                groupValue: selectedLanguage.value,
                onChanged: (value) {
                  if (value != null) selectedLanguage.value = value;
                },
                title: Text('English'),
              ),
              WiredRadioListTile(
                value: 'Spanish',
                groupValue: selectedLanguage.value,
                onChanged: (value) {
                  if (value != null) selectedLanguage.value = value;
                },
                title: Text('Spanish'),
              ),
              WiredRadioListTile(
                value: 'French',
                groupValue: selectedLanguage.value,
                onChanged: (value) {
                  if (value != null) selectedLanguage.value = value;
                },
                title: Text('French'),
              ),
            ],
          ),
          WiredDivider(),
          WiredListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showWiredAboutDialog(
                context: context,
                applicationName: 'My Skribble App',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## Loading States

```dart
class DataLoader extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = useState(true);
    final data = useState<List<String>?>(null);
    final error = useState<String?>(null);

    useEffect(() {
      Future.delayed(Duration(seconds: 2), () {
        data.value = ['Item 1', 'Item 2', 'Item 3'];
        isLoading.value = false;
      });
      return null;
    }, []);

    if (isLoading.value) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WiredCircularProgressIndicator(size: 48),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      );
    }

    if (error.value != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WiredIcon(icon: Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: ${error.value}'),
            SizedBox(height: 16),
            WiredElevatedButton(
              onPressed: () {
                isLoading.value = true;
                error.value = null;
                // Retry loading
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: data.value?.length ?? 0,
      itemBuilder: (context, index) {
        return WiredListTile(
          title: Text(data.value![index]),
        );
      },
    );
  }
}
```

## Search with Filtering

```dart
class SearchScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final searchQuery = useState('');
    final selectedCategory = useState<String?>(null);

    final categories = ['All', 'Work', 'Personal', 'Shopping'];

    final filteredItems = useMemoized(() {
      return items.where((item) {
        final matchesSearch = searchQuery.value.isEmpty ||
            item.title.toLowerCase().contains(searchQuery.value.toLowerCase());
        final matchesCategory = selectedCategory.value == null ||
            selectedCategory.value == 'All' ||
            item.category == selectedCategory.value;
        return matchesSearch && matchesCategory;
      }).toList();
    }, [searchQuery.value, selectedCategory.value]);

    return WiredScaffold(
      appBar: WiredAppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: WiredInput(
              hintText: 'Search items...',
              onChanged: (value) => searchQuery.value = value,
              semanticLabel: 'Search items',
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory.value == category ||
                    (selectedCategory.value == null && category == 'All');
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: WiredChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        selectedCategory.value = category == 'All' ? null : category;
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return WiredListTile(
                  title: Text(item.title),
                  subtitle: Text(item.category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## Animations

```dart
class AnimatedCard extends HookWidget {
  final Widget child;
  final Duration delay;

  const AnimatedCard({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: Duration(milliseconds: 500),
    );

    useEffect(() {
      Future.delayed(delay, () {
        if (context.mounted) {
          controller.forward();
        }
      });
      return null;
    }, []);

    return WiredFadeTransition(
      animation: CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
      child: WiredSlideTransition(
        animation: CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
        ),
        begin: Offset(0, 0.2),
        child: child,
      ),
    );
  }
}

// Usage in a list
class AnimatedList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return AnimatedCard(
          delay: Duration(milliseconds: index * 100),
          child: WiredCard(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Item ${index + 1}'),
            ),
          ),
        );
      },
    );
  }
}
```

## Error Handling with Snackbars

```dart
class ErrorHandler extends HookWidget {
  final Widget child;

  const ErrorHandler({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }

  static void showError(BuildContext context, String message) {
    showWiredSnackBar(
      context,
      content: WiredSnackBarContent(
        child: Row(
          children: [
            WiredIcon(icon: Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
      duration: Duration(seconds: 4),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showWiredSnackBar(
      context,
      content: WiredSnackBarContent(
        child: Row(
          children: [
            WiredIcon(icon: Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
      duration: Duration(seconds: 3),
    );
  }
}
```

## Responsive Layout

```dart
class ResponsiveLayout extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return MobileLayout();
        } else if (constraints.maxWidth < 1200) {
          return TabletLayout();
        } else {
          return DesktopLayout();
        }
      },
    );
  }
}

class MobileLayout extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return WiredScaffold(
      appBar: WiredAppBar(title: Text('My App')),
      body: ContentArea(),
      bottomNavigationBar: WiredBottomNav(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class TabletLayout extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return WiredScaffold(
      body: Row(
        children: [
          WiredNavigationRail(
            destinations: [
              NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(icon: Icon(Icons.search), label: Text('Search')),
              NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
            ],
          ),
          VerticalDivider(width: 1),
          Expanded(child: ContentArea()),
        ],
      ),
    );
  }
}

class DesktopLayout extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return WiredScaffold(
      body: Row(
        children: [
          WiredNavigationDrawer(
            children: [
              WiredDrawerHeader(child: Text('My App')),
              WiredListTile(leading: Icon(Icons.home), title: Text('Home')),
              WiredListTile(leading: Icon(Icons.search), title: Text('Search')),
              WiredListTile(leading: Icon(Icons.person), title: Text('Profile')),
            ],
          ),
          VerticalDivider(width: 1),
          Expanded(child: ContentArea()),
        ],
      ),
    );
  }
}
```

## Next Steps

- [Theming Guide](/getting-started/theming) - Customize the hand-drawn palette
- [Widget Catalog](/widgets/buttons) - Browse all available Wired widgets
- [Core Concepts](/core/architecture) - Understand the rough engine and painting system
- [Migration Guide](/getting-started/migration) - Migrate from Material to Skribble
