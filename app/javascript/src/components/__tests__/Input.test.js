import React from "react";
import { screen, render } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import Input from "../Input";

describe("Input", () => {
  it("renders a label for the input", () => {
    render(<Input name="input" id="input" label="Input" />);
    expect(screen.queryByLabelText("Input")).toBeInTheDocument();
  });

  it("renders a text input for type='text'", () => {
    render(<Input name="input" id="input" label="Input" />);
    const input = screen.queryByLabelText("Input");
    expect(input).toHaveAttribute("type", "text");
  });

  it("renders a date input for type='date'", () => {
    render(<Input name="input" id="input" label="Input" type="date" />);
    const input = screen.queryByLabelText("Input");
    expect(input).toHaveAttribute("type", "date");
  });

  it("renders a phone input for type='phone'", () => {
    render(<Input name="input" id="input" label="Input" type="phone" />);
    const input = screen.queryByLabelText("Input");
    expect(input).toHaveAttribute("type", "phone");
  });

  it("renders help text when provided", () => {
    render(<Input name="input" id="input" label="Input" help="help text" />);
    expect(screen.queryByText("help text")).toBeInTheDocument();
  });

  it("adds classes to the input when className is provided", () => {
    render(<Input name="input" id="input" label="Input" className="mr-2" />);
    const input = screen.queryByLabelText("Input");
    expect(input).toHaveAttribute("class", expect.stringMatching(/mr-2/));
  });

  it("adds classes to the label when labelClassName is provided", () => {
    render(
      <Input name="input" id="input" label="Input" labelClassName="sr-only" />
    );
    const label = screen.queryByText("Input");
    expect(label).toHaveAttribute("class", expect.stringMatching(/sr-only/));
  });

  it("calls the onChange handler", async () => {
    const user = userEvent.setup();

    const onChange = jest.fn();
    render(
      <Input
        name="input"
        id="input"
        label="Input"
        value="hello"
        onChange={onChange}
      />
    );

    const input = screen.queryByLabelText("Input");
    expect(input).toHaveAttribute("value", "hello");

    await user.type(input, " world");

    expect(onChange).toHaveBeenCalled();
  });
});
