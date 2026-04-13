/**
 * Tests for the Bootstrap 5 Tooltip React component (Tooltip.jsx)
 * Verifies data-bs-* attributes (BS5) instead of data-* (BS4)
 */
import React from "react";
import { screen, render } from "@testing-library/react";
import Tooltip from "../../app/javascript/src/components/Tooltip";

jest.mock("../../app/javascript/src/tooltips", () => ({
  activateTooltips: jest.fn(),
}));

const { activateTooltips } = require("../../app/javascript/src/tooltips");

beforeEach(() => {
  jest.clearAllMocks();
});

describe("Tooltip (Bootstrap 5)", () => {
  it("renders the (?) help indicator", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toBeInTheDocument();
  });

  it("uses data-bs-toggle instead of data-toggle (BS5 migration)", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toHaveAttribute("data-bs-toggle", "tooltip");
    expect(tooltip).not.toHaveAttribute("data-toggle");
  });

  it("uses data-bs-html instead of data-html", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toHaveAttribute("data-bs-html", "true");
    expect(tooltip).not.toHaveAttribute("data-html");
  });

  it("uses data-bs-placement instead of data-placement", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toHaveAttribute("data-bs-placement", "bottom");
    expect(tooltip).not.toHaveAttribute("data-placement");
  });

  it("uses data-bs-title instead of data-title", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toHaveAttribute("data-bs-title", "some helper text");
    expect(tooltip).not.toHaveAttribute("data-title");
  });

  it("applies the correct CSS classes", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toHaveClass("daria-tooltip");
    expect(tooltip).toHaveClass("tooltip-header-help");
  });

  it("renders as a span element", () => {
    render(<Tooltip text="some helper text" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip.tagName).toBe("SPAN");
  });

  it("calls activateTooltips on mount", () => {
    render(<Tooltip text="some helper text" />);
    expect(activateTooltips).toHaveBeenCalledTimes(1);
  });

  it("does not call activateTooltips again on re-render", () => {
    const { rerender } = render(<Tooltip text="first" />);
    rerender(<Tooltip text="second" />);
    expect(activateTooltips).toHaveBeenCalledTimes(1);
  });

  it("passes different text props correctly", () => {
    render(<Tooltip text="<b>Bold help</b>" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toHaveAttribute("data-bs-title", "<b>Bold help</b>");
  });

  it("handles empty text prop", () => {
    render(<Tooltip text="" />);
    const tooltip = screen.getByText("(?)");
    expect(tooltip).toHaveAttribute("data-bs-title", "");
  });
});
