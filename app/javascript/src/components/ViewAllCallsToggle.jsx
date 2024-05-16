import React, { useState } from "react";
import mount from "../mount";

const ViewAllCallsToggle = ({ oldCallsCount }) => {
  console.log(`oldCallsCount: ${oldCallsCount}`);
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
      { showOldCalls ? "Limit list" : "View all calls" }
    </button>
  )
};

mount({
  ViewAllCallsToggle,
});
