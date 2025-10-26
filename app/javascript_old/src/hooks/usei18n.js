import { I18n } from "i18n-js";
import translations from "../../locales.json";

export default function () {
  const i18n = new I18n();
  i18n.missingPlaceholder = (_i18n, _placeholder) => "";
  i18n.store(translations);
  return i18n;
}
