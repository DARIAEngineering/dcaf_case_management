import React, { useEffect } from "react";
import { activateTooltips } from "../tooltips";

export default Tooltip = ({text}) => {
  useEffect(() => {
    activateTooltips();
  }, [])

  return (
    <span className="daria-tooltip tooltip-header-help" data-bs-toggle="tooltip" data-bs-html={true} data-bs-placement="bottom" data-bs-title={text}>
      {' '}(?)
    </span>
  )
};