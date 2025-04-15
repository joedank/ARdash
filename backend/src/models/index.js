'use strict';

const { sequelize } = require('../utils/database');
const Sequelize = require('sequelize');

// Manually require each model definition function
const UserModelDefinition = require('./User');
const InvoiceModelDefinition = require('./Invoice');
const InvoiceItemModelDefinition = require('./InvoiceItem');
const EstimateModelDefinition = require('./Estimate');
const EstimateItemModelDefinition = require('./EstimateItem');
const ProductModelDefinition = require('./Product');
const PaymentModelDefinition = require('./Payment');
const SettingsModelDefinition = require('./Settings');
const ClientModelDefinition = require('./Client');
const ClientAddressModelDefinition = require('./ClientAddress');
const ProjectModelDefinition = require('./Project');
const ProjectInspectionModelDefinition = require('./ProjectInspection');
const ProjectPhotoModelDefinition = require('./ProjectPhoto');
const LLMPromptModelDefinition = require('./llmPrompt');
const SourceMapModelDefinition = require('./SourceMap');
const EstimateItemPhotoModelDefinition = require('./estimateItemPhoto');
const EstimateItemAdditionalWorkModelDefinition = require('./estimateItemAdditionalWork');

// Initialize each model
const User = UserModelDefinition(sequelize, Sequelize.DataTypes);
const Invoice = InvoiceModelDefinition(sequelize, Sequelize.DataTypes);
const InvoiceItem = InvoiceItemModelDefinition(sequelize, Sequelize.DataTypes);
const Estimate = EstimateModelDefinition(sequelize, Sequelize.DataTypes);
const EstimateItem = EstimateItemModelDefinition(sequelize, Sequelize.DataTypes);
const Product = ProductModelDefinition(sequelize, Sequelize.DataTypes);
const Payment = PaymentModelDefinition(sequelize, Sequelize.DataTypes);
const Settings = SettingsModelDefinition(sequelize, Sequelize.DataTypes);
const Client = ClientModelDefinition(sequelize, Sequelize.DataTypes);
const ClientAddress = ClientAddressModelDefinition(sequelize, Sequelize.DataTypes);
const Project = ProjectModelDefinition(sequelize, Sequelize.DataTypes);
const ProjectInspection = ProjectInspectionModelDefinition(sequelize, Sequelize.DataTypes);
const ProjectPhoto = ProjectPhotoModelDefinition(sequelize, Sequelize.DataTypes);
const LLMPrompt = LLMPromptModelDefinition(sequelize, Sequelize.DataTypes);
const SourceMap = SourceMapModelDefinition(sequelize, Sequelize.DataTypes);
const EstimateItemPhoto = EstimateItemPhotoModelDefinition(sequelize, Sequelize.DataTypes);
const EstimateItemAdditionalWork = EstimateItemAdditionalWorkModelDefinition(sequelize, Sequelize.DataTypes); // Added initialization

// Store models in db object
const db = {
  User,
  Invoice,
  InvoiceItem,
  Estimate,
  EstimateItem,
  Product,
  Payment,
  Settings,
  Client,
  ClientAddress,
  Project,
  ProjectInspection,
  ProjectPhoto,
  LLMPrompt,
  SourceMap,
  EstimateItemPhoto,
  EstimateItemAdditionalWork
};

// Call associate method for each model
Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

// Export sequelize instance and models
db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
