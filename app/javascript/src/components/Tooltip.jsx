import React, { useEffect } from "react";
import { activateTooltips } from "../tooltips";

export default Tooltip = ({text}) => {
  useEffect(() => {
    activateTooltips();
  }, [])

  return (
    <span className="daria-tooltip tooltip-header-help" data-toggle="tooltip" data-html={true} data-placement="bottom" data-title={text}>
      {' '}(?)
    </span>
  )
};