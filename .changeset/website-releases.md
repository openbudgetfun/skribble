---
skribble_site: minor
---

# The website releases and deploys with monochange

`skribble_site` is now a monochange package that is never published to a registry. It is tagged `skribble_site/v<version>` and gets a GitHub release. Every release deploys the website (landing page, docs, and storybook) through the `Docs Pages` workflow instead of every push to `main`. Changesets with the `user_feat` and `user_fix` types go to the new `user` stream, which is written to the docs' What's new page.
