'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('llm_prompts', {
      id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      prompt_text: {
        type: Sequelize.TEXT,
        allowNull: false
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });

    // Seed with current prompts based on the llm-estimate-prompts.md file
    await queryInterface.bulkInsert('llm_prompts', [
      {
        name: 'initialAnalysis',
        description: 'Initial prompt for analyzing project description',
        prompt_text: `Role: You are an expert estimator analyzing construction project requirements.
Task: Analyze the given project description and identify required measurements and details.
Format: Return a JSON object with:
- required_measurements: array of needed measurements
- suggested_products: array of product types needed
- clarifying_questions: array of specific questions if more detail needed

Example Input: "2000 sq ft roof replacement with tear off"
Example Output: {
  "required_measurements": ["roof_square_footage", "roof_pitch", "number_of_layers"],
  "required_services": ["roof_tear_off", "roof_installation", "cleanup"],
  "clarifying_questions": ["What is the current roof condition?", "Are there any known leak areas?"]
}`,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        name: 'initialAnalysisWithAssessment',
        description: 'Prompt for analyzing project with assessment data',
        prompt_text: `Role: You are an expert estimator analyzing construction project requirements with assessment data.
Task: Analyze the given project description along with the assessment data provided and identify required measurements and details.
Format: Return a JSON object with:
- required_measurements: array of needed measurements (only those not already in assessment data)
- suggested_products: array of product types needed
- clarifying_questions: array of specific questions if more detail needed (fewer needed with assessment data)

Example Input: Project description + Assessment data
Example Output: {
  "required_measurements": ["additional_measurements_needed"],
  "required_services": ["services_based_on_assessment_and_description"],
  "clarifying_questions": ["specific_questions_not_addressed_in_assessment"]
}`,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        name: 'serviceMatch',
        description: 'Service matching for finding catalog items',
        prompt_text: `Role: You are a service specialist matching project needs to available services.
Context: You have access to the following data:
- Project requirements
- Available service catalog
- Measurements and specifications

Task: Match project needs to existing services or suggest new services.
Format: Return a JSON object with:
- matched_services: array of existing service IDs
- new_service_suggestions: array of suggested new services
- estimated_hours: calculated labor hours for each service

Base your estimates on industry standards and best practices.`,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        name: 'laborHoursCalculation',
        description: 'Calculate labor hours for services',
        prompt_text: `Role: You are an estimation expert calculating required labor hours.
Task: Calculate precise labor hours needed for each service based on measurements.
Rules:
- Include standard labor rates
- Account for job complexity factors
- Consider crew size requirements
- Factor in site conditions and access

Format: Return a JSON object with detailed calculations and explanations.`,
        created_at: new Date(),
        updated_at: new Date()
      },
      {
        name: 'newService',
        description: 'Create new services not in catalog',
        prompt_text: `Role: You are a service catalog manager creating new service entries.
Task: Generate complete service specifications for new offerings.
Required Fields:
- name: Clear, standardized service name
- description: Detailed service description
- unit: Appropriate unit of measurement (typically hours or fixed fee)
- type: Service classification
- base_rate: Standard hourly or fixed fee rate

Format: Return a JSON object matching the service catalog schema.`,
        created_at: new Date(),
        updated_at: new Date()
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('llm_prompts');
  }
};
