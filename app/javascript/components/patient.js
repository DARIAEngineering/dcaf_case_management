import React, { Component } from 'react';
import PatientDashboard from './patientDashboard';

class Patient extends React.Component {
    render() {
        return (
            <>
              <h1>Patient Page</h1>
              <PatientDashboard 
              patient={this.props.patient} 
              current_user={this.props.current_user}/>
          </>
        );
    }
}

export default Patient;