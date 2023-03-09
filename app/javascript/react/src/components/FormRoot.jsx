import React from 'react';
import { Toaster } from 'react-hot-toast';
import PropTypes from 'prop-types';

import DynamicForm from './DynamicForm.jsx';
import Global from './context/Global.jsx';

import 'bootstrap/dist/css/bootstrap.min.css';

class FormRoot extends React.Component {
  render() {
    return (
      <Global>
        <DynamicForm schemaId={this.props.schemaId}
          dmpId={this.props.dmpId}
          fragmentId={this.props.fragmentId}
          locale={this.props.locale} />
        <Toaster position="top-center" reverseOrder={false} />
      </Global>
    );
  }
}

FormRoot.propTypes = {
  fragmentId: PropTypes.number,
  dmpId: PropTypes.number,
  schemaId: PropTypes.number,
  locale: PropTypes.string,
};

export default FormRoot;
