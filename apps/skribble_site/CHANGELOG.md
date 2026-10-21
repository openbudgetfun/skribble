# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [1.0.0](https://github.com/openbudgetfun/skribble/releases/tag/skribble_site/v1.0.0) (2026-10-21)

### Features

- **The website releases and deploys with monochange.** `skribble_site` is now a monochange package that is never published to a registry. It is tagged `skribble_site/v<version>` and gets a GitHub release. Every release deploys the website (landing page, docs, and storybook) through the `Docs Pages` workflow instead of every push to `main`. Changesets with the `user_feat` and `user_fix` types go to the new `user` stream, which is written to the docs' What's new page. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #259](https://github.com/openbudgetfun/skribble/pull/259)
