import React, { useState } from "react";

export default Input = ({
  label,
  name,
  id,
  type = "text",
  value: initialValue,
  required,
  help,
  className,
  labelClassName,
  autocomplete = "off",
  onChange,
  tooltip,
  ...props
}) => {
  const [value, setValue] = useState(initialValue || "")
  const labelClassNames = `${required ? 'required' : ''} ${labelClassName || ''}`
  const inputClassNames = `form-control ${className || ''} ${labelClassNames.includes('sr-only') ? 'mt-6' : ''}`

  const handleChange = (e) => {
    setValue(e.target.value)
    onChange?.(e)
  }

  return (
    <div className="form-group">
      <label className={labelClassNames} htmlFor={id}>
        {label}
        {tooltip}
      </label>
      <input type={type} name={name} id={id} required={required} autoComplete={autocomplete} className={inputClassNames} onChange={handleChange} value={value} {...props}></input>
      {help && <small className="form-text text-muted">{help}</small>}
    </div>
  )
};