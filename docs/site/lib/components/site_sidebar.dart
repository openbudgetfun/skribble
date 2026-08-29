import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/components/sidebar.dart';
import 'package:jaspr_content/jaspr_content.dart';

import 'site_paths.dart';

/// Sidebar configuration for Skribble docs.
class SiteSidebar extends StatelessComponent {
  const SiteSidebar({required this.basePath, super.key});

  final String basePath;

  @override
  Component build(BuildContext context) {
    String link(String route) => docsRoute(basePath, route);

    int pageDepth(BuildContext context) {
      final url = context.page.url;
      return url.split('/').where((segment) => segment.isNotEmpty).length;
    }

    return Sidebar(
      currentRoute: link(context.page.url),
      groups: [
        SidebarGroup(
          links: [SidebarLink(text: 'Overview', href: link('/'))],
        ),
        SidebarGroup(
          title: 'Getting Started',
          links: [
            SidebarLink(
              text: 'Installation',
              href: link('/getting-started/installation'),
            ),
            SidebarLink(
              text: 'Quick Start',
              href: link('/getting-started/quick-start'),
            ),
            SidebarLink(
              text: 'Your First Widget',
              href: link('/getting-started/first-widget'),
            ),
            SidebarLink(
              text: 'Theming',
              href: link('/getting-started/theming'),
            ),
          ],
        ),
        SidebarGroup(
          title: 'Core Concepts',
          links: [
            SidebarLink(text: 'Architecture', href: link('/core/architecture')),
            SidebarLink(text: 'Rough Engine', href: link('/core/rough-engine')),
            SidebarLink(text: 'Theme System', href: link('/core/theme-system')),
            SidebarLink(text: 'Hooks & State', href: link('/core/hooks')),
            SidebarLink(text: 'Painters', href: link('/core/painters')),
            SidebarLink(
              text: 'Material Bridge',
              href: link('/core/material-bridge'),
            ),
          ],
        ),
        SidebarGroup(
          title: 'Widget Catalog',
          links: [
            SidebarLink(text: 'Buttons', href: link('/widgets/buttons')),
            SidebarLink(text: 'Inputs', href: link('/widgets/inputs')),
            SidebarLink(text: 'Navigation', href: link('/widgets/navigation')),
            SidebarLink(text: 'Selection', href: link('/widgets/selection')),
            SidebarLink(text: 'Feedback', href: link('/widgets/feedback')),
            SidebarLink(text: 'Layout', href: link('/widgets/layout')),
            SidebarLink(text: 'Icons', href: link('/widgets/icons')),
            SidebarLink(text: 'Cupertino', href: link('/widgets/cupertino')),
          ],
        ),
        SidebarGroup(
          title: 'Live Showcase',
          links: [
            SidebarLink(
              text: 'Live Preview',
              href: link('/showcase/overview'),
            ),
            // Relative to each page URL so it stays depth-correct under any
            // base path: resolves to <base>/storybook/#/font-specimen.
            SidebarLink(
              text: 'Font Specimen',
              href: '${'../' * pageDepth(context)}storybook/#/font-specimen',
            ),
          ],
        ),
        SidebarGroup(
          title: 'Guides',
          links: [
            SidebarLink(
              text: 'Build a Custom Widget',
              href: link('/guides/custom-widgets'),
            ),
            SidebarLink(
              text: 'Custom Painters',
              href: link('/guides/custom-painters'),
            ),
            SidebarLink(
              text: 'Rough Decorations',
              href: link('/guides/rough-decorations'),
            ),
            SidebarLink(
              text: 'Custom Icon Sets',
              href: link('/guides/custom-icons'),
            ),
            SidebarLink(text: 'Testing Widgets', href: link('/guides/testing')),
            SidebarLink(text: 'Screenshots', href: link('/guides/screenshots')),
          ],
        ),
        SidebarGroup(
          title: 'Reference',
          links: [
            SidebarLink(
              text: 'API Overview',
              href: link('/reference/api-overview'),
            ),
            SidebarLink(text: 'Agents', href: link('/reference/agents')),
            SidebarLink(
              text: 'Contributing',
              href: link('/reference/contributing'),
            ),
          ],
        ),
      ],
    );
  }
}
