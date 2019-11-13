// Script run in terminal by @valeriecodes to generate accessibility report
var AxeBuilder = require('axe-webdriverjs'),
    AxeReports = require('axe-reports'),
    webdriver = require('selenium-webdriver'),
    By = webdriver.By,
    until = webdriver.until;

var driver = new webdriver.Builder().forBrowser('chrome') .build();
var AXE_BUILDER = AxeBuilder(driver).withTags(['wcag2a', 'wcag2aa']);
AxeReports.createCsvReportHeaderRow();

driver.get('http://localhost:3000');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.findElement(By.id('user_email')).sendKeys('test@example.com');
driver.findElement(By.id('user_password')).sendKeys('P4ssword');
driver.findElement(By.name('commit')).click();
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.findElement(By.id('line_dc')).click();
driver.findElement(By.name('commit')).click();
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/patients/59ab3eece03a1bdeb41ebb86/edit');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/users');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/users/new');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/users/59ab3ee9e03a1bdeb41ebb68/edit');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/clinics');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/clinics/new');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/clinics/59ab3eebe03a1bdeb41ebb6e/edit');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/configs');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/accountants');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/reports');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.get('http://localhost:3000/users/edit');
AXE_BUILDER.analyze(function (results) {AxeReports.createCsvReportRow(results);});
driver.quit();
