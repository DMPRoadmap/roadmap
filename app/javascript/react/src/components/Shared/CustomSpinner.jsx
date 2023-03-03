import React from 'react';
import { RotatingTriangles } from 'react-loader-spinner';

function CustomSpinner() {
  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        alignContent: 'center',
      }}
    >
      <RotatingTriangles
        visible={true}
        height="80"
        width="80"
        colors={['#2c7dad', '#c6503d', '#FFCC00']}
        ariaLabel="rotating-triangels-loading"
        wrapperStyle={{}}
        wrapperClass="rotating-triangels-wrapper"
      />
    </div>
  );
}

export default CustomSpinner;
