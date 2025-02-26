import React, { useState, useEffect } from "react";

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

  // if we have an onChange handler, we'll manage state like a traditional controlled component (and don't need the useEffect)
  // if we don't have an onChange handler, this component behaves more like an uncontrolled component
  // the useEffect lets us always get the value from the prop
  if (!onChange) {
    useEffect(() => setValue(initialValue), [initialValue]);
  }

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