/**
 * Tests for Bootstrap 5 accessibility class migration in Input and Select.
 * BS4 used "sr-only"; BS5 uses "visually-hidden".
 */
import React from "react";
import { screen, render } from "@testing-library/react";
import Input from "../../app/javascript/src/components/Input";
import Select from "../../app/javascript/src/components/Select";

describe("Input — Bootstrap 5 visually-hidden migration", () => {
  it("adds mt-6 to input when labelClassName includes 'visually-hidden'", () => {
    render(
      <Input
        name="input"
        id="input"
        label="Hidden Label"
        labelClassName="visually-hidden"
      />
    );
    const input = screen.getByLabelText("Hidden Label");
    expect(input.className).toMatch(/mt-6/);
  });

  it("does NOT add mt-6 when labelClassName is 'sr-only' (old BS4 class)", () => {
    render(
      <Input
        name="input"
        id="input"
        label="SR Label"
        labelClassName="sr-only"
      />
    );
    const input = screen.getByLabelText("SR Label");
    expect(input.className).not.toMatch(/mt-6/);
  });

  it("does NOT add mt-6 when no labelClassName is provided", () => {
    render(<Input name="input" id="input" label="Visible Label" />);
    const input = screen.getByLabelText("Visible Label");
    expect(input.className).not.toMatch(/mt-6/);
  });

  it("applies visually-hidden class to the label element", () => {
    render(
      <Input
        name="input"
        id="input"
        label="Hidden"
        labelClassName="visually-hidden"
      />
    );
    const label = screen.getByText("Hidden");
    expect(label.className).toMatch(/visually-hidden/);
  });

  it("preserves required class alongside visually-hidden", () => {
    render(
      <Input
        name="input"
        id="input"
        label="Both"
        labelClassName="visually-hidden"
        required={true}
      />
    );
    const label = screen.getByText("Both");
    expect(label.className).toMatch(/required/);
    expect(label.className).toMatch(/visually-hidden/);
  });

  it("does NOT add mt-6 for unrelated labelClassName values", () => {
    render(
      <Input
        name="input"
        id="input"
        label="Custom"
        labelClassName="custom-class"
      />
    );
    const input = screen.getByLabelText("Custom");
    expect(input.className).not.toMatch(/mt-6/);
  });
});

describe("Select — Bootstrap 5 visually-hidden migration", () => {
  const options = [
    { label: "One", value: 1 },
    { label: "Two", value: 2 },
  ];

  it("adds mt-6 to select when labelClassName includes 'visually-hidden'", () => {
    render(
      <Select
        name="select"
        id="select"
        label="Hidden Label"
        options={options}
        labelClassName="visually-hidden"
      />
    );
    const select = screen.getByLabelText("Hidden Label");
    expect(select.className).toMatch(/mt-6/);
  });

  it("does NOT add mt-6 when labelClassName is 'sr-only' (old BS4 class)", () => {
    render(
      <Select
        name="select"
        id="select"
        label="SR Label"
        options={options}
        labelClassName="sr-only"
      />
    );
    const select = screen.getByLabelText("SR Label");
    expect(select.className).not.toMatch(/mt-6/);
  });

  it("does NOT add mt-6 when no labelClassName is provided", () => {
    render(
      <Select
        name="select"
        id="select"
        label="Visible"
        options={options}
      />
    );
    const select = screen.getByLabelText("Visible");
    expect(select.className).not.toMatch(/mt-6/);
  });

  it("applies visually-hidden class to the label element", () => {
    render(
      <Select
        name="select"
        id="select"
        label="Hidden"
        options={options}
        labelClassName="visually-hidden"
      />
    );
    const label = screen.getByText("Hidden");
    expect(label.className).toMatch(/visually-hidden/);
  });

  it("preserves required class alongside visually-hidden", () => {
    render(
      <Select
        name="select"
        id="select"
        label="Both"
        options={options}
        labelClassName="visually-hidden"
        required={true}
      />
    );
    const label = screen.getByText("Both");
    expect(label.className).toMatch(/required/);
    expect(label.className).toMatch(/visually-hidden/);
  });
});
