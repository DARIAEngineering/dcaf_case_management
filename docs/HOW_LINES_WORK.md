# What does "Lines" mean?

A `line` is the shorthand term for a scoped channel through which an abortion fund
communicates with a patient. It functions as a pipeline so that funds can keep patients
separated if they so choose.

For example, DCAF has separate phone lines for DC, Maryland, and Virginia; these lines have
different case managers on duty and different pools of money. They're separated into their
own lines so patients in a given service area are easier to keep track of.

A case manager can only be working on one line at a time; their line scopes their search
results.

Many (possibly most!) funds operate only one, primary line. The system functions perfectly
well with this use case. However, an instance does need at least one line declared!

## What this means for abortion funds

For abortion funds, this means that adding a new division to how they field calls
is as straightforward as adding a new `Line` object to the database. If a
fund decides to split their phone intake into two, just alter the environment variable.
Note that this requires an engineer or someone with heroku access to complete.

## What this means for engineers

A fund has many (and at least one) `Line` object, and we can set up a new one via `Fund.first.lines.new` in a rails console.

We bubble up `Lines` associated with a fund and and make make them accessible in the app via the [LinesHelper](../app/helpers/lines_helper.rb).
We also have a convenience method, `current_line`, which aliases to a case manager's active line.

Case managers have their lines set as a session variable, and they have to log out to
change it.
