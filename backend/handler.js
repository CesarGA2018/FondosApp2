const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

const dynamoDb = new AWS.DynamoDB.DocumentClient();

const USERS_TABLE = process.env.USERS_TABLE;
const FUNDS_TABLE = process.env.FUNDS_TABLE;
const SUBSCRIPTIONS_TABLE = process.env.SUBSCRIPTIONS_TABLE;
const TRANSACTIONS_TABLE = process.env.TRANSACTIONS_TABLE;

// 🔐 LOGIN
module.exports.login = async (event) => {
  const { email, password } = JSON.parse(event.body);

  const user = await dynamoDb.get({
    TableName: USERS_TABLE,
    Key: { email },
  }).promise();

  if (!user.Item || user.Item.password !== password) {
    return {
      statusCode: 401,
      body: JSON.stringify({ message: 'Credenciales inválidas' }),
    };
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Login exitoso', user: user.Item }),
  };
};

// 🔒 CAMBIO DE CONTRASEÑA
module.exports.changePassword = async (event) => {
  const { email, oldPassword, newPassword } = JSON.parse(event.body);

  const user = await dynamoDb.get({
    TableName: USERS_TABLE,
    Key: { email },
  }).promise();

  if (!user.Item || user.Item.password !== oldPassword) {
    return {
      statusCode: 403,
      body: JSON.stringify({ message: 'Contraseña actual incorrecta' }),
    };
  }

  await dynamoDb.update({
    TableName: USERS_TABLE,
    Key: { email },
    UpdateExpression: 'set password = :newPassword',
    ExpressionAttributeValues: {
      ':newPassword': newPassword,
    },
  }).promise();

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Contraseña actualizada' }),
  };
};

// 💰 SUSCRIPCIÓN A FONDO
module.exports.subscribe = async (event) => {
  const { email, fundId } = JSON.parse(event.body);

  // Obtener usuario
  const userData = await dynamoDb.get({ TableName: USERS_TABLE, Key: { email } }).promise();
  const user = userData.Item;

  // Obtener fondo
  const fundData = await dynamoDb.get({ TableName: FUNDS_TABLE, Key: { id: fundId } }).promise();
  const fund = fundData.Item;

  if (!user || !fund) {
    return { statusCode: 404, body: JSON.stringify({ message: 'Usuario o fondo no encontrado' }) };
  }

  if (user.saldo < fund.montoMinimo) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: `No tiene saldo disponible para vincularse al fondo ${fund.nombre}` }),
    };
  }

  // Descontar saldo
  user.saldo -= fund.montoMinimo;

  // Guardar suscripción
  await dynamoDb.put({
    TableName: SUBSCRIPTIONS_TABLE,
    Item: { userId: email, fundId },
  }).promise();

  // Registrar transacción
  await dynamoDb.put({
    TableName: TRANSACTIONS_TABLE,
    Item: {
      id: uuidv4(),
      userId: email,
      tipo: 'apertura',
      fondo: fund.nombre,
      monto: fund.montoMinimo,
      fecha: new Date().toISOString(),
    },
  }).promise();

  // Actualizar saldo
  await dynamoDb.update({
    TableName: USERS_TABLE,
    Key: { email },
    UpdateExpression: 'set saldo = :saldo',
    ExpressionAttributeValues: { ':saldo': user.saldo },
  }).promise();

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Suscripción exitosa', nuevoSaldo: user.saldo }),
  };
};

// 📋 LISTAR SUSCRIPCIONES
module.exports.getSubscriptionsByUser = async (event) => {
  const { userId } = event.pathParameters;
  try {
    // 1. Obtener las suscripciones del usuario📋
    const result = await dynamoDb.query({
      TableName: SUBSCRIPTIONS_TABLE,
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId,
      },
    }).promise();

    const subscriptions = result.Items;

    // 2. Obtener detalles de los fondos (opcional)
    const fundsDetails = await Promise.all(
      subscriptions.map(async (sub) => {
        const fundData = await dynamoDb.get({
          TableName: FUNDS_TABLE,
          Key: { id: sub.fundId },
        }).promise();
        return fundData.Item;
      })
    );

    return {
      statusCode: 200,
      body: JSON.stringify({ subscriptions: fundsDetails }),
    };
  } catch (error) {
    console.error('Error al obtener suscripciones:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Error al obtener suscripciones' }),
    };
  }
};

// 🚪 CANCELAR SUSCRIPCIÓN
module.exports.unsubscribe = async (event) => {
  const email = event.queryStringParameters?.email;
  const fundId = event.pathParameters.id;

  // Obtener fondo
  const fundData = await dynamoDb.get({ TableName: FUNDS_TABLE, Key: { id: fundId } }).promise();
  const fund = fundData.Item;

  // Eliminar suscripción
  await dynamoDb.delete({
    TableName: SUBSCRIPTIONS_TABLE,
    Key: { userId: email, fundId },
  }).promise();

  // Devolver saldo
  const user = await dynamoDb.get({ TableName: USERS_TABLE, Key: { email } }).promise();
  const nuevoSaldo = user.Item.saldo + fund.montoMinimo;

  await dynamoDb.update({
    TableName: USERS_TABLE,
    Key: { email },
    UpdateExpression: 'set saldo = :saldo',
    ExpressionAttributeValues: { ':saldo': nuevoSaldo },
  }).promise();

  // Registrar transacción
  await dynamoDb.put({
    TableName: TRANSACTIONS_TABLE,
    Item: {
      id: uuidv4(),
      userId: email,
      tipo: 'cancelación',
      fondo: fund.nombre,
      monto: fund.montoMinimo,
      fecha: new Date().toISOString(),
    },
  }).promise();

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Cancelación exitosa', nuevoSaldo }),
  };
};

// 📄 HISTORIAL DE TRANSACCIONES
module.exports.getTransactions = async (event) => {
  const email = event.queryStringParameters?.email;

  const result = await dynamoDb.scan({
    TableName: TRANSACTIONS_TABLE,
    FilterExpression: 'userId = :email',
    ExpressionAttributeValues: { ':email': email },
  }).promise();

  return {
    statusCode: 200,
    body: JSON.stringify(result.Items),
  };
};

// 👀 VER TRANSACCIONES DE OTRO USUARIO (Consultor)
module.exports.getTransactionsByUser = async (event) => {
  const userId = event.pathParameters.userId;

  const result = await dynamoDb.scan({
    TableName: TRANSACTIONS_TABLE,
    FilterExpression: 'userId = :userId',
    ExpressionAttributeValues: { ':userId': userId },
  }).promise();

  return {
    statusCode: 200,
    body: JSON.stringify(result.Items),
  };
};

module.exports.getPortfolios = async (event) => {
  const params = {
    TableName: process.env.FUNDS_TABLE,
  };

  try {
    const data = await dynamoDb.scan(params).promise();

    return {
      statusCode: 200,
      body: JSON.stringify({ portfolios: data.Items }),
    };
  } catch (error) {
    console.error("Error al obtener los fondos:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Error al obtener los fondos' }),
    };
  }
};
