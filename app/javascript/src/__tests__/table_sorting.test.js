/**
 * @jest-environment jsdom
 */
import Tablesort from 'tablesort';

jest.mock('tablesort', () => {
  const MockTablesort = jest.fn(() => ({ sort: jest.fn() }));
  return MockTablesort;
});

beforeEach(() => {
  document.body.innerHTML = '';
  Tablesort.mockClear();
});

afterEach(() => {
  document.body.innerHTML = '';
});

const loadModule = () => {
  jest.resetModules();
  return import('../../app/javascript/src/table_sorting');
};

describe('initSortableTables', () => {
  it('initializes Tablesort on tables with data-sort attribute', async () => {
    document.body.innerHTML = `
      <table data-sort><thead><tr><th>Name</th></tr></thead></table>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(Tablesort).toHaveBeenCalledTimes(1);
    expect(Tablesort).toHaveBeenCalledWith(document.querySelector('table[data-sort]'));
  });

  it('does not initialize Tablesort on tables without data-sort', async () => {
    document.body.innerHTML = '<table><thead><tr><th>Name</th></tr></thead></table>';
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(Tablesort).not.toHaveBeenCalled();
  });

  it('caches Tablesort instance on _tablesort property', async () => {
    document.body.innerHTML = '<table data-sort><thead><tr><th>Col</th></tr></thead></table>';
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    const table = document.querySelector('table[data-sort]');
    expect(table._tablesort).toBeTruthy();
  });

  it('does not re-initialize when _tablesort already exists', async () => {
    document.body.innerHTML = '<table data-sort><thead><tr><th>Col</th></tr></thead></table>';
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(Tablesort).toHaveBeenCalledTimes(1);
  });

  it('handles multiple sortable tables', async () => {
    document.body.innerHTML = `
      <table data-sort id="t1"><thead><tr><th>A</th></tr></thead></table>
      <table data-sort id="t2"><thead><tr><th>B</th></tr></thead></table>
      <table id="t3"><thead><tr><th>C</th></tr></thead></table>
    `;
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(Tablesort).toHaveBeenCalledTimes(2);
  });

  it('responds to turbo:load event', async () => {
    document.body.innerHTML = '<table data-sort><thead><tr><th>Col</th></tr></thead></table>';
    await loadModule();
    document.dispatchEvent(new Event('turbo:load'));

    expect(Tablesort).toHaveBeenCalledTimes(1);
  });

  it('responds to turbo:frame-load event', async () => {
    document.body.innerHTML = '<table data-sort><thead><tr><th>Col</th></tr></thead></table>';
    await loadModule();
    document.dispatchEvent(new Event('turbo:frame-load'));

    expect(Tablesort).toHaveBeenCalledTimes(1);
  });

  it('does nothing when no tables are present', async () => {
    document.body.innerHTML = '<div>No tables here</div>';
    await loadModule();
    document.dispatchEvent(new Event('DOMContentLoaded'));

    expect(Tablesort).not.toHaveBeenCalled();
  });
});
