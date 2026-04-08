import React from "react";
import { screen, render } from "@testing-library/react";
import Tooltip from "../Tooltip";

jest.mock("../../tooltips", () => ({
  activateTooltips: jest.fn(),
}));

describe("Tooltip", () => {
  it("renders a span with appropriate data attrs", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toBeInTheDocument();
    expect(tooltip).toHaveAttribute("data-bs-toggle", "tooltip");
    expect(tooltip).toHaveAttribute("data-bs-html", "true");
    expect(tooltip).toHaveAttribute("data-bs-placement", "bottom");
    expect(tooltip).toHaveAttribute("data-bs-title", "some helper text");
  });
});
