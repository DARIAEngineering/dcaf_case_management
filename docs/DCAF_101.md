# How Does DCAF Work?

DCAF has many volunteer **case managers** who answer **patient** calls coming in through a hotline phone number and voicemail. DCAF case management software helps the case managers keep track of patient status and needs.

The workflow is similar to many Customer Relationship Manager (CRM) systems. After patients leave a voicemail, the case managers (our users) return their calls and assist patients in navigating the process of scheduling an appointment and raising funds. If the patient is short on money, after a series of phone calls we issue a pledge to support their visit to a clinic. If a patient takes advantage of the pledge and complete their abortion, our accounting team logs that as a **fulfillment**.

[![DCAF High Level User Flow](https://cloud.githubusercontent.com/assets/12372787/11200243/45b1a5de-8ca2-11e5-876c-da0f738041f0.jpg)](https://cloud.githubusercontent.com/assets/12372787/11200243/45b1a5de-8ca2-11e5-876c-da0f738041f0.jpg)

Our case managers work either a one week or a half week shift where they are in charge of one of three lines (DC, VA, or MD/Nationwide). A patient may be touched by several case managers over a period of several weeks, which is why DCAF needed a case management system that more accurately records these interactions across case managers.

## Important concepts, in bullet form
* Case manager: The DCAF team member on duty, who checks the voice mailbox, makes a list of patients to call, sends money to clinics, and in general handles all patient-facing duties during a half-week shift.
* Patients: Individuals who call DCAF asking for assistance securing an abortion.
* Call list: A case manager figures out who to call back based on a voice mailbox and knowledge about whose appointments are coming up, and turns that into a Call List.
* Pledges: DCAF sends money to clinics in the form of pledges; the case manager faxes a voucher, called a pledge, to the clinic saying that DCAF is good for a certain amount, and to send the signed voucher back to us for payment.
* Fulfillments: When we receive a pledge back from a clinic to indicate that a patient cashed in their voucher, we mark that as a fulfillment.

**1. Initial Contact**

A patient calls DCAF and leaves a voicemail with their name and callback number. The patient may also include additional information of use to a case manager, such as how far along the patient is, when and where their appointment is, etc.

**2. Creating the Call List**

The Case Manager listens to voicemail inbox and creates call list (of patients who need to be called by the Case Manager) via the DARIA system with patient names, phone numbers, statuses, notes of previous calls if applicable, and appointment date if known. Case managers are able to search the database via partial or full phone number or name. If a patient is already in the DARIA system, that patient is added to the call list. If the patient is calling for the first time, a case manager can simultaneously create them in the system and add a new patient to the call list at. The call list is able to be rearranged depending on an individual case manager’s preference for triaging call priority.

**3. Calling the Patients**

The Case Manager calls a patient, which is recorded in the DARIA system as either able to reach the patient, left a voicemail, or unable to reach the patient. 

If the Case Manager is able to reach the patient, they will talk the patient through intake, fundraising, or pledging, depending on where the patient is in the process. This will include gathering data on the patient’s case, referring the patients to clinics and other funding sources. At the end of the call, if a pledge is not made, the Case Manager will tell the patient their next steps, including confirming that the patient needs to call DCAF back before a pledge can be made. 

A patient may go through Steps 1-3 several times before a pledge is made.

**4. Pledging**

If a patient has completed their fundraising efforts, the Case Manager will confirm their information is correct and record a pledge in the DARIA system. A pledge is any amount of money sent to a clinic for use by a patient. These pledges are capped depending on how far along in a pregnancy the patient is. In the future, the system will autocreate a pledge form, but currently, Case Managers must handwrite the pledge to be sent. 

The pledge is then sent to the appropriate clinic through an online faxing system. The Case Manager will then call the clinic to confirm receipt of pledge. 

**6. Appointment**

The patient goes to their appointment and uses the pledge sent by DCAF. The clinic fills out the appropriate information at the bottom of the pledge form and returns the completed pledge to DCAF for payment.

If the patient does not make their appointment for whatever reason, the patient will call DCAF back and a new pledge will be made. The pledges are made out for a specific patient and appointment date, so at the very minimum the date on the pledge will need to be changed. Sometimes, however, the price of the appointment will increase, and if possible, DCAF will also raise the pledge to help the patient bridge that gap, so the pledge amount will be changed as well.

**7. Fulfillment**

Completed pledge forms are checked against the DARIA system by the DCAF accountant. The case is marked paid and closed. Payment is recorded in DCAF’s ledger and sent to the clinic.
