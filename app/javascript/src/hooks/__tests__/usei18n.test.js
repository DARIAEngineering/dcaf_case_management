import usei18n from "../usei18n";

describe("usei18n", () => {
  it("returns an object with the `t` function", () => {
    const i18n = usei18n();
    expect(i18n.t).not.toBeNull()
    expect(typeof(i18n.t)).toEqual("function")
  });

  it("translates keys that exist in locales.json", () => {
    const i18n = usei18n();
    expect(i18n.t('common.add')).toEqual('Add')
  })

  it("doesn't translates keys that don't exist in locales.json", () => {
    const i18n = usei18n();
    expect(i18n.t('random.key')).toMatch(/missing/)
  })
});