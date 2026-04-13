/**
 * Tests for Bootstrap 5 tooltip initialization (tooltips.js)
 * Verifies BS5 native Tooltip API usage instead of jQuery .tooltip()
 */
import { activateTooltips } from '../../app/javascript/src/tooltips';

// Mock the bootstrap module with Tooltip class
const mockTooltipInstance = { dispose: jest.fn() };
const mockGetInstance = jest.fn();
const MockTooltipConstructor = jest.fn(() => mockTooltipInstance);
MockTooltipConstructor.getInstance = mockGetInstance;

jest.mock('bootstrap', () => ({
  Tooltip: MockTooltipConstructor,
}));

beforeEach(() => {
  document.body.innerHTML = '';
  jest.clearAllMocks();
  mockGetInstance.mockReturnValue(null);
});

describe('activateTooltips — Bootstrap 5 native API', () => {
  describe('.daria-tooltip elements', () => {
    it('creates a new bootstrap.Tooltip for each .daria-tooltip element', () => {
      document.body.innerHTML = `
        <span class="daria-tooltip">Tip 1</span>
        <span class="daria-tooltip">Tip 2</span>
      `;

      activateTooltips();

      expect(MockTooltipConstructor).toHaveBeenCalledTimes(2);
      const firstEl = document.querySelectorAll('.daria-tooltip')[0];
      expect(MockTooltipConstructor).toHaveBeenCalledWith(firstEl);
    });

    it('skips elements that already have a Tooltip instance (getInstance check)', () => {
      document.body.innerHTML = '<span class="daria-tooltip">Tip</span>';
      mockGetInstance.mockReturnValue(mockTooltipInstance);

      activateTooltips();

      expect(MockTooltipConstructor).not.toHaveBeenCalled();
    });

    it('handles zero .daria-tooltip elements gracefully', () => {
      document.body.innerHTML = '<div>No tooltips here</div>';

      activateTooltips();

      expect(MockTooltipConstructor).not.toHaveBeenCalled();
    });
  });

  describe('.tooltip-header-input elements', () => {
    it('injects a help span and creates Tooltip on input labels', () => {
      document.body.innerHTML = `
        <div class="mb-3">
          <label class="tooltip-header-input">Label</label>
          <input class="form-control" data-tooltip-text="Help text" />
        </div>
      `;

      activateTooltips();

      const helpSpan = document.querySelector('.tooltip-header-help');
      expect(helpSpan).not.toBeNull();
      expect(helpSpan.textContent).toBe('(?)');
      expect(MockTooltipConstructor).toHaveBeenCalledWith(helpSpan, {
        html: true,
        placement: 'bottom',
        title: 'Help text',
      });
    });

    it('does not double-inject help span if already present', () => {
      document.body.innerHTML = `
        <div class="mb-3">
          <label class="tooltip-header-input">
            Label <span class="tooltip-header-help">(?)</span>
          </label>
          <input class="form-control" data-tooltip-text="Help text" />
        </div>
      `;

      activateTooltips();

      const helpSpans = document.querySelectorAll('.tooltip-header-help');
      expect(helpSpans).toHaveLength(1);
    });

    it('does not create Tooltip if no .form-control input exists', () => {
      document.body.innerHTML = `
        <div class="mb-3">
          <label class="tooltip-header-input">Label</label>
        </div>
      `;

      activateTooltips();

      // Help span injected but no Tooltip created since no input
      expect(MockTooltipConstructor).not.toHaveBeenCalled();
    });

    it('skips labels not inside a .mb-3 or .form-group container', () => {
      document.body.innerHTML = `
        <div>
          <label class="tooltip-header-input">Orphan label</label>
          <input class="form-control" data-tooltip-text="Help text" />
        </div>
      `;

      activateTooltips();

      // Help span injected but no Tooltip since no .mb-3/.form-group ancestor
      expect(MockTooltipConstructor).not.toHaveBeenCalled();
    });
  });

  describe('.tooltip-header-checkbox elements', () => {
    it('injects a help span and creates Tooltip on checkbox labels', () => {
      document.body.innerHTML = `
        <div>
          <label class="tooltip-header-checkbox">Check</label>
          <input type="checkbox" data-tooltip-text="Checkbox help" />
          <span class="tooltip-header-help">(?)</span>
        </div>
      `;

      // Clear to account for the injected span logic
      jest.clearAllMocks();
      mockGetInstance.mockReturnValue(null);

      activateTooltips();

      expect(MockTooltipConstructor).toHaveBeenCalledWith(
        expect.any(Element),
        expect.objectContaining({
          html: true,
          placement: 'bottom',
          title: 'Checkbox help',
        })
      );
    });

    it('does not create Tooltip when help span already has an instance', () => {
      document.body.innerHTML = `
        <div>
          <label class="tooltip-header-checkbox">Check</label>
          <input type="checkbox" data-tooltip-text="Checkbox help" />
          <span class="tooltip-header-help">(?)</span>
        </div>
      `;
      mockGetInstance.mockReturnValue(mockTooltipInstance);

      activateTooltips();

      // getInstance returns truthy, so constructor should not be called for
      // any checkbox tooltip (daria-tooltip also skipped)
      expect(MockTooltipConstructor).not.toHaveBeenCalled();
    });
  });

  describe('event listener registration', () => {
    it('registers activateTooltips on DOMContentLoaded', () => {
      const spy = jest.spyOn(document, 'addEventListener');
      // Re-import to trigger the module-level addEventListener calls
      jest.isolateModules(() => {
        require('../../app/javascript/src/tooltips');
      });

      const calls = spy.mock.calls.map(([event]) => event);
      expect(calls).toContain('DOMContentLoaded');
      spy.mockRestore();
    });

    it('registers activateTooltips on show.bs.modal', () => {
      const spy = jest.spyOn(document, 'addEventListener');
      jest.isolateModules(() => {
        require('../../app/javascript/src/tooltips');
      });

      const calls = spy.mock.calls.map(([event]) => event);
      expect(calls).toContain('show.bs.modal');
      spy.mockRestore();
    });
  });
});
