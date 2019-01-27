# Adopting DARIA

If you are a fund considering adopting DARIA as your case management system of record, this may answer common questions about how things work. We also have a sandbox/training app where no actual patient data lives for experimenting. You can check out the sandbox [here](https://sandbox.dcabortionfund.org) with username `test@test.com`, password `P4ssword`. Be sure to check out the 'Admin Tools' section to understand how DARIA can be customized to your organization.

If after reading below, you feel that DARIA's a good fit for your organization, just reach out to us on the Code4DC Slack -- [sign up here](https://codefordc.org/resources/slack.html) -- in the #dcaf_case_management channel.

## The case management workflow

DARIA's case management workflow was designed to mirror existing practices used in case management. Volunteer case managers answer patient calls coming in through a hotline phone number and voicemail. DCAF case management software helps the case managers keep track of patient status and needs.

The workflow is similar to many Customer Relationship Manager (CRM) systems. After patients leave a voicemail, the case managers return their calls and assist patients in navigating the process of scheduling an appointment and raising funds. If the patient is short on money, after a series of phone calls we issue a pledge to support their visit to a clinic. If a patient takes advantage of the pledge and complete their abortion, our accounting team logs that as a fulfillment.

Read more about our workflow at: 
https://github.com/DCAFEngineering/dcaf_case_management/blob/master/docs/DCAF_101.md

## Administration toolkit

DARIA provides a number of workflows to administer and report on your funds activities. Analysts are able to export an anonymized spreadsheet for analysis; administrators are able to keep track of which clinics your fund  are and aren't working with; and your accounting team can use a specialized workflow to mark which pledges have been cashed.

## Your DARIA instance and its data is yours

Every fund's DARIA instance is separate from others. Your DARIA instance and its data is completely yours to use. DCAF and other DARIA funds do not have access to your data.

## Security

By reaching out to a fund, a patient is implicitly trusting us to be discreet and safeguard their personal data. To make good on funds' promise to keep our patients safe and offer them the best advice and support we can, our development team's top priority is keeping patient data secure and safe through deploying industry best practices and security monitoring softwares. 

Additionally, we know any tech is only as secure as the people using it. A fund should also maintain secure data collection and usage practices at the individual case manager level, including deploying two factor authentication on their google accounts and using DARIA's features rather than using potentially compromising patient information in email communications.

Find our complete security review at:
https://github.com/DCAFEngineering/dcaf_case_management/blob/master/docs/SECURITY.md

## How to migrate

Data migration is a manual process using a custom data entry form within DARIA. Funds should migrate data as close to the go-live date as possible. Plan to have a team of volunteers in your fund complete the migration. One person should be able to migrate approximately 200 patients over a weekend.

We suggest breaking this down as follows:

* Determine how much data to migrate (suggestion: current fiscal year or calendar year)
* Recruit data entry volunteers, planning for 1 volunteer per 200 patients for 2 days of data entry
* Break out data by volunteer to ensure no patient duplication

## Costs

DARIA costs start at $84 a year ($7 a month for 12 months), paid to DCAF once a year. This covers your share of server fees, and gets your fund its own URL and database. Funds which see a heavy amount of patient traffic (2,000+ new patients per year) may need to invest in a database upgrade at an additional $216 a year after the first year.

## Support and Maintenance

The DARIA engineering team will automatically update your instance with patches and new features. App monitoring is in place to alert the engineering team of any major outages.
