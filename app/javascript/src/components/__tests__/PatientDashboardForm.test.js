import React from "react";
import { screen, render } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import PatientDashboardForm from "../PatientDashboardForm";

jest.mock("../Tooltip", () => () => <div>tooltip</div>);

let mockReturnValue = {};
const mockPut = jest.fn(() => Promise.resolve(mockReturnValue));
jest.mock("../../hooks/useFetch", () => () => ({
  put: mockPut,
}));

const mockFlashRender = jest.fn();
jest.mock("../../hooks/useFlash", () => () => ({
  render: mockFlashRender,
}));

describe("PatientDashboardForm", () => {
  it("renders an input for name", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
      />
    );

    expect(screen.queryByLabelText("First and last name")).toBeInTheDocument();
  });

  it("renders a select for last_menstrual_period_weeks", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
      />
    );

    expect(
      screen.queryByLabelText("Weeks along at intake")
    ).toBeInTheDocument();
  });

  it("renders a select for last_menstrual_period_days", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
      />
    );

    expect(screen.queryByLabelText("Days along at intake")).toBeInTheDocument();
  });

  it("renders an input for appointment_date", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
      />
    );

    expect(screen.queryByLabelText("Appointment date")).toBeInTheDocument();
  });

  it("renders an input for primary_phone", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
      />
    );

    expect(screen.queryByLabelText("Phone number")).toBeInTheDocument();
  });

  it("renders an input for pronouns", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
      />
    );

    expect(screen.queryByLabelText("Pronouns")).toBeInTheDocument();
  });

  it("renders an input for status", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
      />
    );

    expect(screen.queryByLabelText("Status")).toBeInTheDocument();
  });

  it("renders a link to delete when admin", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const patientPath = "/patients/1";
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
        patientPath={patientPath}
        isAdmin={true}
      />
    );

    expect(
      screen.getByRole("link", { name: "Delete duplicate patient record" })
    ).toBeInTheDocument();
  });

  it("does not render a link to delete when not admin", () => {
    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const patientPath = "/patients/1";
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
        patientPath={patientPath}
      />
    );

    expect(
      screen.queryByRole("link", { name: "Delete duplicate patient record" })
    ).not.toBeInTheDocument();
  });

  it("autosaves on input change", async () => {
    const user = userEvent.setup();

    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const patientPath = "/patients/1";
    const formAuthenticityToken = "token";
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
        patientPath={patientPath}
        formAuthenticityToken={formAuthenticityToken}
      />
    );

    const input = screen.queryByLabelText("First and last name");
    await user.type(input, "P");

    expect(mockPut).toHaveBeenCalledWith(patientPath, {
      name: "P",
      authenticity_token: formAuthenticityToken,
    });
  });

  it("autosaves on select change", async () => {
    const user = userEvent.setup();

    const patient = {};
    const weeksOptions = [
      { label: "0 weeks", value: 0 },
      { label: "1 week", value: 1 },
    ];
    const daysOptions = [
      { label: "0 days", value: 0 },
      { label: "1 day", value: 1 },
    ];
    const patientPath = "/patients/1";
    const formAuthenticityToken = "token";
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
        patientPath={patientPath}
        formAuthenticityToken={formAuthenticityToken}
      />
    );

    const select = screen.queryByLabelText("Weeks along at intake");
    await user.selectOptions(
      select,
      screen.getByRole("option", { name: "1 week" })
    );

    expect(mockPut).toHaveBeenCalledWith(patientPath, {
      last_menstrual_period_weeks: "1",
      authenticity_token: formAuthenticityToken,
    });
  });

  it("renders a flash message after autosave", async () => {
    const user = userEvent.setup();

    mockReturnValue = {
      patient: { name: "P" },
      flash: { notice: "Patient data successfully saved" },
    };

    const patient = {};
    const weeksOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const daysOptions = [
      { label: 0, value: 0 },
      { label: 1, value: 1 },
    ];
    const patientPath = "/patients/1";
    const formAuthenticityToken = "token";
    render(
      <PatientDashboardForm
        patient={patient}
        weeksOptions={weeksOptions}
        daysOptions={daysOptions}
        patientPath={patientPath}
        formAuthenticityToken={formAuthenticityToken}
      />
    );

    const input = screen.queryByLabelText("First and last name");
    await user.type(input, "P");

    expect(mockFlashRender).toHaveBeenCalledWith(mockReturnValue.flash);
  });
});
