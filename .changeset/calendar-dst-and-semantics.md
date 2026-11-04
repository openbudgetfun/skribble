---
skribble: patch
---

# Calendars count days correctly across clock changes

`WiredCalendar` and `WiredDateRangePickerDialog` built their grids by adding 24-hour steps, so in time zones with daylight saving a month that crossed a clock change showed one day twice, lost its last day, or stopped circling the selected date. Days are now counted on the calendar.

`WiredCalendar` also follows a new `selected` value from its parent, names every day for screen readers (`Monday, June 15, 2026`, with its selected state), announces its `<<` and `>>` controls, inks its titles and circle with the theme, shrinks weekday names and the month title to one line instead of wrapping them, and no longer needs a Material ancestor. The range picker inks its selection with the theme's `borderColor`, so it shows in dark themes, makes the hatching between the endpoints visible, marks the endpoints as selected for screen readers, and stacks Cancel and OK when they do not fit.
