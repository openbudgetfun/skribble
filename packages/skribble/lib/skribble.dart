/// Hand-drawn UI components for Flutter.
///
/// skribble provides sketchy, hand-drawn widgets that give your app
/// a unique, informal aesthetic.
///
/// The exports are grouped by audience:
///
/// - **Canvas, motion & rough engine** — the extension points for custom
///   painters and animations; see the custom painters guide.
/// - **Widgets & theme** — the catalog of ready-made wired components plus
///   the `WiredTheme` system, palettes, roughness levels, and fonts.
///
/// Library-internal machinery (for example `WiredPainter`, the
/// `CustomPainter` adapter that `WiredCanvas` creates) intentionally lives
/// under `package:skribble/src/…` and is not part of the public contract.
/// The rough engine exports below are likewise curated: the configuration,
/// generator, filler, and drawing data structures that the docs promise are
/// public, while pure engine internals (geometry helpers, filler plumbing)
/// are not exported.
library;

// ---------------------------------------------------------------------------
// Canvas, motion & rough engine — extension points for custom painters
// ---------------------------------------------------------------------------

export 'src/canvas/wired_canvas.dart';
export 'src/canvas/wired_ink_splash.dart';
export 'src/canvas/wired_painter_base.dart';
export 'src/motion/wired_draw.dart';
export 'src/motion/wired_ink_interaction.dart';
export 'src/motion/wired_motion.dart';
export 'src/rough/skribble_rough.dart'
    show
        DashedFiller,
        DotFiller,
        DrawConfig,
        Drawable,
        Filler,
        FillerConfig,
        Generator,
        HachureFiller,
        HatchFiller,
        NoFiller,
        Op,
        OpSet,
        OpSetType,
        OpType,
        PointD,
        Randomizer,
        Rough,
        RoughBoxDecoration,
        RoughBoxShape,
        RoughDrawing,
        RoughDrawingStyle,
        SolidFiller,
        ZigZagFiller;

// ---------------------------------------------------------------------------
// Widgets & theme
// ---------------------------------------------------------------------------

export 'src/skribble_app.dart' hide resolveWiredAppTheme;
export 'src/skribble_icon.dart';
export 'src/skribble_localizations.dart';
export 'src/wired_about_dialog.dart';
export 'src/wired_about_list_tile.dart';
export 'src/wired_animated_icon.dart';
export 'src/wired_app_bar.dart';
export 'src/wired_autocomplete.dart';
export 'src/wired_avatar.dart';
export 'src/wired_badge.dart';
export 'src/wired_base.dart';
export 'src/wired_bottom_app_bar.dart';
export 'src/wired_bottom_nav.dart';
export 'src/wired_bottom_sheet.dart';
export 'src/wired_brand_icon.dart';
export 'src/wired_button.dart';
export 'src/wired_calendar.dart';
export 'src/wired_calendar_date_picker.dart';
export 'src/wired_card.dart';
export 'src/wired_carousel_view.dart';
export 'src/wired_checkbox.dart';
export 'src/wired_checkbox_list_tile.dart';
export 'src/wired_chip.dart';
export 'src/wired_choice_chip.dart';
export 'src/wired_circular_progress.dart';
export 'src/wired_color_picker.dart';
export 'src/wired_combo.dart';
export 'src/wired_context_menu.dart';
export 'src/wired_cupertino_action_sheet.dart';
export 'src/wired_cupertino_activity_indicator.dart';
export 'src/wired_cupertino_alert_dialog.dart';
export 'src/wired_cupertino_button.dart';
export 'src/wired_cupertino_date_picker.dart';
export 'src/wired_cupertino_form_section.dart';
export 'src/wired_cupertino_list_section.dart';
export 'src/wired_cupertino_list_tile.dart';
export 'src/wired_cupertino_navigation_bar.dart';
export 'src/wired_cupertino_picker.dart';
export 'src/wired_cupertino_scaffold.dart';
export 'src/wired_cupertino_search_text_field.dart';
export 'src/wired_cupertino_segmented_control.dart';
export 'src/wired_cupertino_slider.dart';
export 'src/wired_cupertino_switch.dart';
export 'src/wired_cupertino_tab_bar.dart';
export 'src/wired_cupertino_text_field.dart';
export 'src/wired_cupertino_timer_picker.dart';
export 'src/wired_data_table.dart';
export 'src/wired_date_picker.dart';
export 'src/wired_date_range_picker.dart';
export 'src/wired_dialog.dart';
export 'src/wired_dismissible.dart';
export 'src/wired_divider.dart';
export 'src/wired_doodle.dart';
export 'src/wired_doodle_kind.dart';
export 'src/wired_drawer.dart';
export 'src/wired_drawer_header.dart';
export 'src/wired_elevated_button.dart';
export 'src/wired_expansion_panel_list.dart';
export 'src/wired_expansion_tile.dart';
export 'src/wired_fab.dart';
export 'src/wired_filled_button.dart';
export 'src/wired_filter_chip.dart';
export 'src/wired_font.dart';
export 'src/wired_form.dart';
export 'src/wired_grid_tile.dart';
export 'src/wired_icon.dart';
export 'src/wired_icon_button.dart';
export 'src/wired_icon_registry.dart';
export 'src/wired_input.dart';
export 'src/wired_input_chip.dart';
export 'src/wired_license_page.dart';
export 'src/wired_list_tile.dart';
export 'src/wired_loader.dart';
export 'src/wired_loading_indicator.dart';
export 'src/wired_loading_screen.dart';
export 'src/wired_logo.dart';
export 'src/wired_material_banner.dart';
export 'src/wired_menu_bar.dart';
export 'src/wired_mergeable_material.dart';
export 'src/wired_navigation_bar.dart';
export 'src/wired_navigation_drawer.dart';
export 'src/wired_navigation_rail.dart';
export 'src/wired_outlined_button.dart';
export 'src/wired_paginated_data_table.dart';
export 'src/wired_palette.dart';
export 'src/wired_popup_menu.dart';
export 'src/wired_progress.dart';
export 'src/wired_radio.dart';
export 'src/wired_radio_list_tile.dart';
export 'src/wired_range_slider.dart';
export 'src/wired_reorderable_list_view.dart';
export 'src/wired_roughness.dart';
export 'src/wired_scaffold.dart';
export 'src/wired_scrollbar.dart';
export 'src/wired_search_anchor.dart';
export 'src/wired_search_bar.dart';
export 'src/wired_segmented_button.dart';
export 'src/wired_selectable_text.dart';
export 'src/wired_selection_area.dart';
export 'src/wired_skeleton.dart';
export 'src/wired_slider.dart';
export 'src/wired_sliver_app_bar.dart';
export 'src/wired_snack_bar.dart';
export 'src/wired_stepper.dart';
export 'src/wired_svg_icon_data.dart';
export 'src/wired_switch.dart';
export 'src/wired_switch_list_tile.dart';
export 'src/wired_tab_bar.dart';
export 'src/wired_text_area.dart';
export 'src/wired_text_button.dart';
export 'src/wired_theme.dart';
export 'src/wired_theme_scope.dart';
export 'src/wired_time_picker.dart';
export 'src/wired_toggle.dart';
export 'src/wired_toggle_buttons.dart';
export 'src/wired_tooltip.dart';

// ---------------------------------------------------------------------------
// COMPATIBILITY LAYER (transitional) — the sanctioned exception to the
// no-Material/no-Cupertino rule.
//
// Everything above is core: it imports only flutter/widgets.dart and below.
// The exports below live in lib/src/compat/ and may import material/cupertino
// so that apps can migrate to Skribble incrementally: theme conversion both
// ways, Material widgets inside a SkribbleApp, and Wired widgets inside an
// existing Material or Cupertino app. Nothing in the core may depend on them,
// and they must not grow Material parity.
//
// See docs/site/content/core/material-bridge.md.
// Kept as a trailing group rather than interleaved alphabetically so the core
// export list above stays easy to audit for Material/Cupertino leaks.
// ignore: directives_ordering
export 'src/compat/compat.dart';
