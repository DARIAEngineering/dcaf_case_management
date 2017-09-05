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
is as straightforward as changing the `DARIA_LINES` environment variable. If a
fund decides to split their phone intake into two, just alter the environment variable.
Note that this requires an engineer or someone with heroku access to complete.

## What this means for engineers

In [config/initializers/env_var_constants.rb](../config/initializers/env_var_constants.rb),
we set an array of the lines `LINES`. (We default it to the DCAF use case, which operates
lines for DC, MD, and VA.) It reads from the environment variable `DARIA_LINES` -- this
value defines the lines for an instance.

We bubble that up and make it accessible in the app via the [LinesHelper](../app/helpers/lines_helper.rb).
We also have a convenience method, `current_line`, which aliases to the session variable.

Case managers have their lines set as a session variable, and they have to log out to
change it.

