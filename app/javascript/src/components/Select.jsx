import React from "react";

export default Select = ({
  label,
  name,
  id,
  options = [],
  required,
  help,
  className,
  labelClassName,
  onChange,
  value,
  ...props
}) => {
  const labelClassNames = `${required ? 'required' : ''} ${labelClassName || ''}`

  const selectClassNames = `form-control ${className || ''} ${labelClassNames.includes('sr-only') ? 'mt-4' : ''}`

  const selectedValue = !!value || value === 0 ? value : ""
  if (!!onChange) {
    props["value"] = selectedValue
  } else {
    props["defaultValue"] = selectedValue
  }

  return (
    <div className="form-group">
      <label className={labelClassNames} htmlFor={id}>
        {label}
      </label>
      <select name={name} id={id} className={selectClassNames} required={required} onChange={onChange} {...props}>
        {options.map(opt => <option key={opt.value} value={opt.value}>{opt.label}</option>)}
      </select>
      {help && <small className="form-text text-muted">{help}</small>}
    </div>
  )
};