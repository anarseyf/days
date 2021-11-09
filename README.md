# Days Countdown app

Count down a number of days, up to one year. Optionally select the start date (defaults to today). Easy-to-use, low-friction interface.

* Calendar to select a start date
* Notification on the last day of countdown (at 7:00AM, can be changed or turned off).
* Bars to illustrate days passed (see screenshots)

### Code

#### View Controllers

* [DaysSelectorViewController.swift](Days/DaysSelectorViewController.swift), [+Extensions.swift](Days/DaysSelectorViewController+Extensions.swift) - Initial screen
* [CalendarViewController.swift](Days/CalendarViewController.swift) - Start date calendar
* [MonthViewController.swift](Days/MonthViewController.swift) - Single month within the calendar
* [CountdownViewController.swift](Days/CountdownViewController.swift) - Active countdown screen
* [ProgressViewController.swift](Days/ProgressViewController.swift) - Embedded view showing the bars

#### Models

* [CalendarModel.swift](Days/CalendarModel.swift)
* [MonthModel.swift](Days/MonthModel.swift)
* [DayModel.swift](Days/DayModel.swift)
* [TimerModel.swift](Days/TimerModel.swift)

#### Notifications

* [NotificationsHandler.swift](Days/NotificationsHandler.swift)

### Screenshots

<img src="https://github.com/anarseyf/days/blob/master/documentation/screenshots/screenshot-1.png" width=33%> <img src="https://github.com/anarseyf/days/blob/master/documentation/screenshots/screenshot-2.png" width=33%> <img src="https://github.com/anarseyf/days/blob/master/documentation/screenshots/screenshot-3.png" width=33%> <img src="https://github.com/anarseyf/days/blob/master/documentation/screenshots/screenshot-4.png" width=33%> <img src="https://github.com/anarseyf/days/blob/master/documentation/screenshots/screenshot-5.png" width=33%> <img src="https://github.com/anarseyf/days/blob/master/documentation/screenshots/screenshot-6.png" width=33%>

### TODO/Future features

* Optional title (supported, just not surfaced)
* Multiple countdowns
* Store timestamps instead of dates (takes up too much storage)
* Avoid recalculating calendar model on date change
* Extract Calendar as standalone component/library
