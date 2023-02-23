import React from 'react';
import { Toaster } from 'react-hot-toast';
import PropTypes from 'prop-types';

import DynamicForm from './DynamicForm.jsx';
import Global from './context/Global.jsx';

import 'bootstrap/dist/css/bootstrap.min.css';
import 'react-draft-wysiwyg/dist/react-draft-wysiwyg.css';

class FormRoot extends React.Component {
  render() {
    console.log(this.props.fragmentId, this.props.dmpId, this.props.schemaId);
    return (
      <Global>
        <DynamicForm schemaId={this.props.schemaId}
          dmpId={this.props.dmpId}
          fragmentId={this.props.fragmentId}
          locale={this.props.locale} xsrf={this.props.xsrf} />
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
  xsrf: PropTypes.string,
};

export default FormRoot;
