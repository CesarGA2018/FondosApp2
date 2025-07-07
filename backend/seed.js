const AWS = require('aws-sdk');

AWS.config.update({ region: 'us-east-1' });

const dynamoDb = new AWS.DynamoDB.DocumentClient();

const users = [
  {
    email: "admin@btg.com",
    password: "admin123",
    nombre: "Admin BTG",
    rol: "admin",
    saldo: 500000,
  },
  {
    email: "consultor@btg.com",
    password: "consultor123",
    nombre: "Consultor Financiero",
    rol: "consultor",
    saldo: 500000,
  },
  {
    email: "cliente1@btg.com",
    password: "cliente123",
    nombre: "Cliente Uno",
    rol: "cliente",
    saldo: 500000,
  },
  {
    email: "cliente2@btg.com",
    password: "cliente123",
    nombre: "Cliente Dos",
    rol: "cliente",
    saldo: 500000,
  }
];

const fondos = [
  { id: "1", nombre: "FPV_BTG_PACTUAL_RECAUDADORA", montoMinimo: 75000, categoria: "FPV" },
  { id: "2", nombre: "FPV_BTG_PACTUAL_ECOPETROL", montoMinimo: 125000, categoria: "FPV" },
  { id: "3", nombre: "DEUDAPRIVADA", montoMinimo: 50000, categoria: "FIC" },
  { id: "4", nombre: "FDO-ACCIONES", montoMinimo: 250000, categoria: "FIC" },
  { id: "5", nombre: "FPV_BTG_PACTUAL_DINAMICA", montoMinimo: 100000, categoria: "FPV" },
];

async function seed() {
  for (const user of users) {
    await dynamoDb.put({
      TableName: 'UsersTable',
      Item: user,
    }).promise();
    console.log(`✅ Usuario creado: ${user.email}`);
  }

  for (const fund of fondos) {
    await dynamoDb.put({
      TableName: 'FundsTable',
      Item: fund,
    }).promise();
    console.log(`✅ Fondo creado: ${fund.nombre}`);
  }

  console.log("🚀 Datos iniciales cargados con éxito.");
}

seed().catch(console.error);
