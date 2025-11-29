import React from "react";
import { screen, render } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import Select from "../Select";

describe("Select", () => {
  it("renders a label for the select", () => {
    const options = [
      { label: "One", value: 1 },
      { label: "Two", value: 2 },
    ];
    render(
      <Select name="select" id="select" label="Select" options={options} />
    );
    expect(screen.queryByLabelText("Select")).toBeInTheDocument();
  });

  it("renders help text when provided", () => {
    const options = [
      { label: "One", value: 1 },
      { label: "Two", value: 2 },
    ];
    render(
      <Select
        name="select"
        id="select"
        label="Select"
        options={options}
        help="help text"
      />
    );
    expect(screen.queryByText("help text")).toBeInTheDocument();
  });

  it("adds classes to the select when className is provided", () => {
    const options = [
      { label: "One", value: 1 },
      { label: "Two", value: 2 },
    ];
    render(
      <Select
        name="select"
        id="select"
        label="Select"
        options={options}
        className="mr-2"
      />
    );
    const select = screen.queryByLabelText("Select");
    expect(select).toHaveAttribute("class", expect.stringMatching(/mr-2/));
  });

  it("adds classes to the label when labelClassName is provided", () => {
    const options = [
      { label: "One", value: 1 },
      { label: "Two", value: 2 },
    ];
    render(
      <Select
        name="select"
        id="select"
        label="Select"
        options={options}
        labelClassName="sr-only"
      />
    );
    const label = screen.queryByText("Select");
    expect(label).toHaveAttribute("class", expect.stringMatching(/sr-only/));
  });

  it("renders an uncontrolled select when no onChange handler is provided", async () => {
    const user = userEvent.setup();

    const options = [
      { label: "One", value: 1 },
      { label: "Two", value: 2 },
    ];
    render(
      <Select
        name="select"
        id="select"
        label="Select"
        options={options}
        value="hello"
      />
    );

    expect(screen.getByRole("option", { name: "One" }).selected).toBe(true);

    await user.selectOptions(
      // Find the select element
      screen.getByRole("combobox"),
      // Find and select the option
      screen.getByRole("option", { name: "Two" })
    );
    expect(screen.getByRole("option", { name: "Two" }).selected).toBe(true);
  });

  it("renders a controlled select when an onChange handler is provided", async () => {
    const user = userEvent.setup();

    const onChange = jest.fn();
    const options = [
      { label: "One", value: 1 },
      { label: "Two", value: 2 },
    ];
    render(
      <Select
        name="select"
        id="select"
        label="Select"
        options={options}
        value="hello"
        onChange={onChange}
      />
    );

    expect(screen.getByRole("option", { name: "One" }).selected).toBe(true);

    await user.selectOptions(
      // Find the select element
      screen.getByRole("combobox"),
      // Find and select the option
      screen.getByRole("option", { name: "Two" })
    );

    expect(onChange).toHaveBeenCalled();
  });
});
