# skribble_lints

Centralized lint rules for the skribble workspace, built on top of `very_good_analysis`.

On top of `very_good_analysis`, it turns on `public_member_api_docs`, so every public class, member, and parameter in a package that includes these rules needs a `///` doc comment. Generated `*.g.dart` files are excluded.
