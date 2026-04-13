/**
 * @jest-environment jsdom
 */
import Sortable from 'sortablejs';

jest.mock('sortablejs', () => ({
  create: jest.fn(() => ({})),
}));

beforeEach(() => {
  document.body.innerHTML = '';
  Sortable.create.mockClear();
  global.fetch = jest.fn(() => Promise.resolve({ ok: true }));
});

afterEach(() => {
  document.body.innerHTML = '';
  delete global.fetch;
});

const loadModule = () => {
  jest.resetModules();
  return import('../../app/javascript/src/call_list_drag_and_drop');
};

describe('call_list_drag_and_drop', () => {
  const buildCallList = () => {
    document.body.innerHTML = `
      <meta name="csrf-token" content="test-csrf-token">
      <table id="call_list">
        <tbody>
          <tr class="patient-data" id="patient_1"><td>Patient 1</td></tr>
          <tr class="patient-data" id="patient_2"><td>Patient 2</td></tr>
          <tr class="patient-data" id="patient_3"><td>Patient 3</td></tr>
        </tbody>
      </table>
    `;
  };

  it('initializes Sortable on call_list tbody', async () => {
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(Sortable.create).toHaveBeenCalledTimes(1);
    const tbody = document.querySelector('#call_list tbody');
    expect(Sortable.create).toHaveBeenCalledWith(tbody, expect.objectContaining({
      animation: 150,
      handle: '.patient-data',
      draggable: '.patient-data',
      ghostClass: 'ui-state-highlight',
      chosenClass: 'active-item-shadow',
    }));
  });

  it('does not initialize when call_list element is missing', async () => {
    document.body.innerHTML = '<div>No call list</div>';
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(Sortable.create).not.toHaveBeenCalled();
  });

  it('sends PATCH request with new order on onEnd', async () => {
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const onEndCb = Sortable.create.mock.calls[0][1].onEnd;
    const mockItem = document.querySelector('.patient-data');

    onEndCb({
      item: mockItem,
    });

    expect(global.fetch).toHaveBeenCalledWith(
      '/call_lists/reorder_call_list',
      expect.objectContaining({
        method: 'PATCH',
        headers: expect.objectContaining({
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-CSRF-Token': 'test-csrf-token',
        }),
      })
    );

    const body = global.fetch.mock.calls[0][1].body;
    expect(body).toContain('order[]=patient_1');
    expect(body).toContain('order[]=patient_2');
    expect(body).toContain('order[]=patient_3');
  });

  it('highlights dropped row cells temporarily', async () => {
    jest.useFakeTimers();
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const onEndCb = Sortable.create.mock.calls[0][1].onEnd;
    const item = document.querySelector('.patient-data');

    onEndCb({ item });

    const td = item.querySelector('td');
    expect(td.style.backgroundColor).toBe('#ece0ff');

    jest.advanceTimersByTime(500);
    expect(td.style.backgroundColor).toBe('');

    jest.useRealTimers();
  });

  it('includes CSRF token from meta tag', async () => {
    buildCallList();
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const onEndCb = Sortable.create.mock.calls[0][1].onEnd;
    onEndCb({ item: document.querySelector('.patient-data') });

    const headers = global.fetch.mock.calls[0][1].headers;
    expect(headers['X-CSRF-Token']).toBe('test-csrf-token');
  });

  it('handles missing CSRF token gracefully', async () => {
    document.body.innerHTML = `
      <table id="call_list">
        <tbody>
          <tr class="patient-data" id="p1"><td>P1</td></tr>
        </tbody>
      </table>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const onEndCb = Sortable.create.mock.calls[0][1].onEnd;
    expect(() => {
      onEndCb({ item: document.querySelector('.patient-data') });
    }).not.toThrow();
  });

  it('falls back to call_list element when no tbody exists', async () => {
    document.body.innerHTML = `
      <div id="call_list">
        <div class="patient-data" id="p1">Patient 1</div>
      </div>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(Sortable.create).toHaveBeenCalledTimes(1);
    // Falls back to callList itself since there's no tbody
    const callList = document.getElementById('call_list');
    expect(Sortable.create).toHaveBeenCalledWith(callList, expect.any(Object));
  });
});
