import React, { useState } from "react";
import mount from "../mount";
import { usei18n } from "../hooks";

const ViewAllCallsToggle = ({ oldCallsCount }) => {
  const i18n = usei18n();

  if (oldCallsCount <= 0) return null;

  const [showOldCalls, setShowOldCalls] = useState(false)

  const toggleCallLog = () => {
    // in a perfect world, we'd move .old-calls into React but this is fine for now
    oldCallsElements = document.querySelectorAll(".old-calls")
    oldCallsElements.forEach(el => el.classList.toggle("d-none"));
    setShowOldCalls(!showOldCalls)
  }

  return (
    <button className="btn btn-link" onClick={toggleCallLog}>
      {showOldCalls ? i18n.t('patient.call_log.table.view_less') : i18n.t('patient.call_log.table.view_more')}
    </button>
  )
};

mount({
  ViewAllCallsToggle,
});
