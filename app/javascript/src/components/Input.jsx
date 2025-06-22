import React, { useState } from "react";

export default Input = ({
  label,
  name,
  id,
  type = "text",
  value,
  required,
  help,
  className,
  labelClassName,
  autocomplete = "off",
  onChange,
  tooltip,
  ...props
}) => {
  // if we don't have an onChange handler, this component is an uncontrolled component
  // if we have an onChange handler, we'll manage state like a traditional controlled component
  const Component = !onChange ? UncontrolledInput : ControlledInput
  return <Component
    label={label}
    name={name}
    id={id}
    type={type}
    value={value}
    required={required}
    help={help}
    className={className}
    labelClassName={labelClassName}
    autocomplete={autocomplete}
    onChange={onChange}
    tooltip={tooltip}
    {...props}
  />
};


const UncontrolledInput = ({
  label,
  name,
  id,
  type,
  value,
  required,
  help,
  className,
  labelClassName,
  autocomplete,
  onChange,
  tooltip,
  ...props
}) => {
  const labelClassNames = `${required ? 'required' : ''} ${labelClassName || ''}`
  const inputClassNames = `form-control ${className || ''} ${labelClassNames.includes('sr-only') ? 'mt-6' : ''}`

  return (
    <div className="form-group">
      <label className={labelClassNames} htmlFor={id}>
        {label}
        {tooltip}
      </label>
      <input type={type} name={name} id={id} required={required} autoComplete={autocomplete} className={inputClassNames} onChange={onChange} value={value} {...props}></input>
      {help && <small className="form-text text-muted">{help}</small>}
    </div>
  )
}

const ControlledInput = ({
  value: initialValue,
  onChange,
  ...props
}) => {
  const [value, setValue] = useState(initialValue || "")
  const handleChange = (e) => {
    setValue(e.target.value)
    onChange?.(e)
  }

  return <UncontrolledInput
    value={value}
    onChange={handleChange}
    {...props}
  />
}

