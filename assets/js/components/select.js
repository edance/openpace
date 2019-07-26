import React, { useState } from 'react';
import ReactSelect from 'react-select';

export default function Select(props) {
  const [value, setValue] = useState(props.value);

  return (
    <>
      <ReactSelect
          isClearable
          onChange={setValue}
          value={value}
          {...props}
      />

      { value && <input name={name} type="hidden" value={value.value} /> }
    </>
  );
}
