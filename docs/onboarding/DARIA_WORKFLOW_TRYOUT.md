# Trying out the DARIA workflow

These are instructions for trying out DARIA as a case manager, to get a feel for how we want you to manage patients, etc.

DARIA is designed around a warm-line process, where case managers are checking voicemails and creating a list of people to call back.

## Logging in

* Go to [sandbox.dariaservices.com](https://sandbox.dariaservices.com).
* Use the username `test@example.com` and the password `AbortionsAreAHumanRight1`.
* Click the `Sign in with Password` button.
* Select the `DC` line and click `Get Started`.

## Using your call list

This takes you to the main case manager view. You will see:

* A budget bar, detailing amounts of money that have been set aside for pledges that week
* A prompt to build your call list by searching for patients
* Patients on your call list, tied to your user account
* Patients you've called from your call list, in a section called `Completed Calls`
* Flagged patients (these are visible to all case managers)
* Call line activity log

### Finding and creating new patients

Case managers can use the search bar to find or create patients in DARIA.

* Look up a patient that already exists by entering their phone number: `123-123-1230` and clicking the magnifying glass.
* Look up a patient that already exists by entering part of their name: `Reporting` and clicking the magnifying glass.
* Create a new patient by entering a name not currently in the system. (Try your favorite band.) This will show a form to create a new patient. Fill out the form and click the `Add new patient` button.

### Calling someone off your list

The call list lets case managers make a list of calls based on their own methods. From the call list, a case manager can record a call to a patient or remove them from the call list.

* In your call list, find the patient you created.
* Click the blue phone icon on the right side. This pops up some information about the patient you can refer to.
* Click the `I reached the patient` button to log a call.
* This will redirect you to a page where you can log additional details about the patient.

## Using the patient view

This view is roughly equivalent to a row in a spreadsheet, except laid out in a way that helps keep a case manager's focus on their conversation. Click the links on the lower left hand side to see the information you can track. Try doing the following:

* Logging that the patient has an appointment at `Sample Clinic 2 - VA` three days from today.
* Mark that a patient is receiving an additional $50 pledge from another fund (hint: we call these `External Pledges` and they're in the `Abortion Information` tab).
* Make a new note about the patient.

### Pledging

Pledge amounts are recorded under `Abortion Information`. Once you've logged your pledge amount in `Sandbox Pledge`, you're ready to send the pledge:

* Click the `Submit Pledge` button
* Confirm the pledge details
* Click next until you see a checkbox that says `I Sent the Pledge`.

## Administrative functions

These functions are not available to regular case managers and require elevated permissions. These are all accessible

* Accounting: Patients with submitted pledges can be viewed separately under `Admin > Accounting` in the top navbar by Admins and Data Volunteers.
* CSV export: An anonymized, PII-free export of DARIA data for analysis is available under `Admin > Export anonymized CSV` for Admins and Data Volunteers.
* User management: Admins are allowed to create new case managers, lock accounts, etc. under `Admin > User Management`.
* Clinic management: Admins can update clinics you are currently working with under `Admin > Clinic Management`.
* Configs: DARIA makes some things adjustable on a per-app basis. Admins can view and edit them in `Admin > Config Management`.

## Further reading

* A complete data dictionary of what the DARIA app collects can be found here:
https://github.com/DARIAEngineering/dcaf_case_management/blob/main/docs/DATA_DICTIONARY.md
* More information about the data collection principles of the DARIA engineering team are here:
https://github.com/DARIAEngineering/dcaf_case_management/blob/main/docs/OUR_DATA_COLLECTION_PRACTICES.md
