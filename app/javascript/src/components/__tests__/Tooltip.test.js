import React from "react";
import { screen, render } from "@testing-library/react";
import Tooltip from "../Tooltip";

jest.mock("../../tooltips", () => ({
  activateTooltips: jest.fn(),
}));

describe("Select", () => {
  it("renders a span with appropriate data attrs", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toBeInTheDocument();
    expect(tooltip).toHaveAttribute("data-toggle", "tooltip");
    expect(tooltip).toHaveAttribute("data-html", "true");
    expect(tooltip).toHaveAttribute("data-placement", "bottom");
    expect(tooltip).toHaveAttribute("data-title", "some helper text");
  });
});
