# Our data collection practices

Due to the sensitive data we're collecting, we take data security extremely seriously. A part of that is limiting the data we actually collect.

Our guiding principles on data are as follows: 

* If we have to collect it and it can be used to identify someone, we should store it only as long as necessary for administrative purposes and then hash it.
* If it could result in harm to the patient if it gets out, we should avoid storing it unless an absolute necessity, and avoid storing it if there's a feasible way to work around it. We're okay with this inconveniencing our case managers.
* We're okay with storing data long term for reporting and program information, provided it isn't identifiable data. If it's potentially sensitive or could be used in conjunction with other information to identify a patient, we should avoid exporting it.
* Only data necessary for reporting and aggregation should be available for aggregation.

## What we store and don't store

Primarily, we store patient contact information. We also store some data about how a patient interacts with our fund and case managers, such as calls our case managers make to them, notes they take in the process, and financial information. We also store some demographic data to improve service delivery via reporting, such as race or ethnicity, limited geography, and similar stuff.

We explicitly try to avoid storing anything that could get a patient in trouble in the event of a data breach.

### An example of something borderline that we removed: Immigration status

We took the ability to flag someone as undocumented out of the app in early 2017 after deciding the potential harm outweighed the immediate benefits.

Storing this information had a benefit of flagging for case managers to use a heightened level of discretion, point them toward certain services known to be friendly to this community, and so forth. However, under this model, a data breach would result in a list of names, immediately associated with phone numbers (and potentially a location they were going to be at on a given day).

The benefit to a case manager is real and meaningful, but the potential risk and harm to clients was severe enough that we decided to remove it.

### An example of something borderline that we store but don't export: Special circumstances

We store flags related to a patient's circumstances, so that if a patient is dealing with a complex situation our case managers can direct them to helpful resources.

However, in the unlikely event that an anonymized export were to leak, we wouldn't want potentially harmful information or intimate details about a patient to leak along with them. So while we store that information, it's accessible only through the case manager workflow and not through the exports.

## How long we store it

We store anonymized reporting data indefinitely; personally identifiable fields are wiped after. We're hashing out exact rules but see [this issue](https://github.com/DCAFEngineering/dcaf_case_management/issues/812) for progress.
