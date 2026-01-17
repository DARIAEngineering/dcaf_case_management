class AddConsentToSurveyToPatient < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :consent_to_survey, :boolean, comment: 'An indicator that a patient is game to be surveyed'
  end
end
