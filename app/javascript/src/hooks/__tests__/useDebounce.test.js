import useDebounce from "../useDebounce";
import { act } from "@testing-library/react";

describe("useDebounce", () => {
  describe("debounce", () => {
    it("calls the debounced function once after a set interval", () => {
      jest.useFakeTimers();
      const { debounce } = useDebounce();
      const func = jest.fn();
      const timeout = 300;
      const debouncedFunc = debounce(func, timeout);
      act(() => debouncedFunc());
      act(() => debouncedFunc());
      act(() => debouncedFunc());
      act(() => jest.advanceTimersByTime(500));
      expect(func).toHaveBeenCalledTimes(1);
      jest.useRealTimers();
    });
  });
});
