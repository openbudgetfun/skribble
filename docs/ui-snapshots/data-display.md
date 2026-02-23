# Data Display Components

Hand-drawn widgets for displaying structured data, dates, times, and multi-step flows.

## WiredCalendar

A full calendar widget with month/year navigation and date selection.

![WiredCalendar](https://f005.backblazeb2.com/file/skribble-screenshots/data-display/wired-calendar.png)

- Month and year navigation arrows
- Date selection with visual feedback
- Google Fonts integration for styling
- Hand-drawn cell borders

## WiredDatePicker

A date picker dialog wrapping the calendar widget.

![WiredDatePicker](https://f005.backblazeb2.com/file/skribble-screenshots/data-display/wired-date-picker.png)

- Dialog wrapper around `WiredCalendar`
- Returns selected `DateTime`
- Hand-drawn dialog border

## WiredTimePicker

A clock-style time picker with drag-to-adjust.

![WiredTimePicker](https://f005.backblazeb2.com/file/skribble-screenshots/data-display/wired-time-picker.png)

- Hour and minute fields
- Custom clock face with hand painters
- Drag interaction for time adjustment
- `_HandPainter` for clock hand rendering

## WiredStepper

A multi-step stepper interface for guided flows.

![WiredStepper](https://f005.backblazeb2.com/file/skribble-screenshots/data-display/wired-stepper.png)

- Custom `WiredStep` class for each step
- Animated step indicators with checkmarks
- Vertical line connectors between steps
- Active, complete, and pending states
