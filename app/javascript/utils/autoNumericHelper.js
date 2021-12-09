import AutoNumeric from 'autonumeric';

export const AutoNumericHelper = {
  init(classname) {
    if ($(classname).length > 0) {
      // eslint-disable-next-line no-new
      new AutoNumeric(
        classname,
        { digitGroupSeparator: ' ', decimalPlaces: '0' },
      );
    }
  },
};

export default AutoNumericHelper;
