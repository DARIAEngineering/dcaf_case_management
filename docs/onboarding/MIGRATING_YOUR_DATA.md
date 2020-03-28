# Data Migration into DARIA

This process is for bringing historical data into the DARIA system from a previous system. It allows the fund to access recent patient data for patients who are still working with the fund to receive care.

We have found that a new DARIA fund should migrate a minimum of 6 weeks of data, which ensures most of the active patients are accounted for. You may want to migrate more data if patients have a longer engagement with your fund, or if you want more complete data for the fiscal year.

We assume here that you have compared how you keep track of patient data to how DARIA keeps track, and have a plan for how to match your data model to DARIA's data model. Please reach out to the DARIA team for assistance with this if necessary.

## Planning for your migration

Funds should migrate data as close to the go-live date as possible. Plan to have a team of volunteers in your fund complete the migration. One person should be able to migrate approximately 200 patients over a weekend.

We suggest breaking this down as follows:

* Determine how much data to migrate (suggestion: current fiscal year or calendar year; a minimum of six weeks).
* Recruit data entry volunteers, planning for 1 volunteer per 200 patients for 2 days of data entry.
* For multiple volunteers, break out data by volunteer to ensure no patient duplication.

## Actually migrating your data

Mechanically, data migration is a manual process using a custom data entry form within DARIA. This helps the process go faster by letting volunteers copy-paste data into form fields for patients.

See it in the sandbox at: [sandbox.dcabortionfund.org/data_entry](https://sandbox.dcabortionfund.org/data_entry).

Instructions for using the data migration form tool:

* Log in as normal
* Go to YOUR_URL.herokuapp.com/data_entry
* Enter the patient information from the spreadsheet, EXCEPT FOR notes, external pledges, calls, practical support data, and fulfillment data
* Press the `Submit` button to the create the
* This will redirect you to the patient's regular DARIA view. Manually add any notes, calls, external pledges, practical support, and fulfillment data.
  * In the `Notes` tab: Copy text from "Comments & Patient Story" to the text box, if applicable.
  * In the `Call Log` tab: Click on the `Record new call` link. Select option that best describes your contact with that patient, if applicable.
  * In the `Abortion Information` tab: Enter in External Pledges, our term for contributions from other funds, if applicable.
  * In the `Practical Support` tab: Enter in any Practical Support information for that patient, if applicable.
  * In the `Fulfillment` tab: If the patient has a sent pledge, enter in the pledge payout information for this patient, if applicable. Note that this tab won't be visible if the patient doesn't have a sent pledge.
* This patient is now considered entered for our purposes here! Navigate back to YOUR_URL.herokuapp.com/data_entry to start the next one.
* Repeat until complete.
