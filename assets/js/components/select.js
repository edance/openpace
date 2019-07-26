import React from 'react';
import ReactSelect from 'react-select';

export default function Select(props) {
  return (
    <ReactSelect
        className="basic-single"
        classNamePrefix="select"
        isClearable
        {...props}
    />
  );
}
