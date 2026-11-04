---
skribble_site: patch
---

# The site build rejects options it does not know

`dart run apps/skribble_site/bin/build.dart` used to ignore any option it did not recognize, so a typo such as `--basepath=/skribble/` quietly built the site for `/`. It now prints the unknown option and the usage, and exits with status 64.
