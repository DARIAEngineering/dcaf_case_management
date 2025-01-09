# Our security practices

By reaching out to a fund, a patient is implicitly trusting us to be discreet and safeguard their personal data. To make good on funds' promise to keep our patients safe and offer them the best advice and support we can, our development team's top priority is keeping patient data secure and safe.

This document outlines some specific practices that we follow as a development team to keep our data secure and safe. If you'd like to discuss particulars, please reach out to us.

## Business practices

### User management

We ensure that every unique volunteer is able to have their own account.

Given that a very common attack vector for an app like ours is a user account hijack, we take a few steps to harden against this potential threat.

1. We give users the option to log in through Google, which lets us take advantage of Google's user security best practices. To this end, we encourage our users to set up 2-factor authentication on their accounts.
2. We use an industry-standard library, `devise`, for user authentication, to avoid having to write and maintain our own secure authentication system.
3. We have a 2-factor option for users on our application, on top of that.
4. We recommend against using a password, but for users who insist on logging in via a password, we enforce a high password standard. We also send email notifications on password change, so that potential intrusions can be flagged as soon as possible.

### Limting data access

We follow the principle of least use; most users are permissioned to see only necessary data.

For users with heightened permissions, we have a user-accessible way to bulk-export anonymized data for aggregation. We don't have a user-accessible way to bulk-lookup data.

### Limiting data we collect

See [our data collection practices document](OUR_DATA_COLLECTION_PRACTICES.md) for a fuller accounting of what we collect and why.

### Throwing away data after we're done with it

After a certain period of time, we make it a point to get rid of sensitive patient information as much as possible, leaving only what's necessary for analysis and anonymizing or deleting everything else.

### We are not HIPAA compliant

HIPAA compliance applies to people storing certain protected health information. That is not our whole deal and we try to avoid handling that sort of data. There are many tedious reasons why we don't strive to be HIPAA compliant as a goal, although we've adopted many of the best practices around data handling regardless.

## Application-level

### Data encryption

We have a few approaches we leverage here. The first is that we use a database service that uses disk encryption (commonly called 'encryption at rest'), meaning that if someone were to pop the drive out it wouldn't be readable by another computer. This works similar to the disk encryption on PCs/Macs, like FileVault. This covers all data in DARIA.

For some particularly sensitive pieces of data (that we don't have to fuzzy-search on), we encrypt that data on the application level. This means that it's sent to the application encrypted and the app knows how to decode it into something readable, providing an additional layer of safety beyond encryption at rest. This is similar to how passwords are stored and used.

### Code review

The first line of defense is a regular review of code as it is developed and deployed. We accomplish this through two main means.

1. **All code changes are submitted as pull requests**, which means that they are submitted to the project as proposed changes before making it into the codebase. This gives the team a chance to review and offer suggestions before code gets to the point where anyone interacts with it. Furthermore, code can only be approved and deployed by a select group of project leaders.

2. After a change is merged into the codebase, we **reploy a fresh version of the app to a testing sandbox environment**. This environment is isolated from our production system. This environment gives us a chance to confirm that code changes work as intended, do not introduce any security holes, and meet the project's high standard of quality.

### Vulnerability monitoring

Our project uses a variety of industry standard tools to ensure our existing codebase stays secure and free of vulnerabilities. Of particular note:

1. **Ruby-audit**: This tool keeps track of known vulnerabilities in the Ruby language.
2. **Bundler-audit**: This tool keeps track of known vulnerabilities in the libraries we use to construct the app.
3. **Brakeman Pro**: This tool scans our codebase for code that could lead to OWASP vulnerabilities, such as SQL injection.

New vulnerabilities tracked by these libraries alert us, and we deal with them quickly regardless of whether or not we think we're affected by the particular vulnerabiliy. We tend to address new CVEs in under a week most of the time.

### Penetration testing

On occasion we retain (friendly) experts to penetration test our software, and address any relevant discoveries. The last time we did this was spring of 2023.

### Automated testing

We use it a point to write unit and integration tests for our codebase, which ensures a high level of code quality. This means that we break our app into individual features and functions, and have code which runs them all and confirms that they produce the intended output.

### Vendor selection and hosting

For hosting purposes, we have selected service vendors which are backed by significant security engineering teams. This enables us to effectively have security professionals monitoring our apps against intrusion, and allows us to benefit from their practices to safeguard our own data.

### SSL

All traffic going to and from any environment we're in is protected by SSL, per industry best practice.

### Other attack vectors

We have solutions in place to prevent common attack vectors. Keeping our framework, Rails, up to date protects us from a lot of common attacks. In addition, we use the libraries `rack-attack` and `secure_headers` to prevent some less common attack vectors, such as DDOS attacks and javascript injection.
