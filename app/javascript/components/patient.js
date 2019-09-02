import React, { Component } from 'react';
import PatientDashboard from './patientDashboard';

class Patient extends React.Component {
    render() {
        return (
            <React.Fragment>
              <h1>Patient Page</h1>
              <PatientDashboard patient={this.props.patient}/>
          </React.Fragment>
        );
    }
}

export default Patient;