module.exports.notify = async (event) => {
  try {
    const body = JSON.parse(event.body);

    const { email, tipo, medio, fondo } = body;

    // Validaciones básicas
    if (!email || !tipo || !medio || !fondo) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: 'Faltan campos requeridos: email, tipo, medio, fondo' }),
      };
    }

    if (!['email', 'sms'].includes(medio)) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: 'Medio no soportado: debe ser "email" o "sms"' }),
      };
    }

    if (!['apertura', 'cancelación'].includes(tipo)) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: 'Tipo no válido: debe ser "apertura" o "cancelación"' }),
      };
    }

    // Mensaje simulado
    const mensaje = `Notificación de ${tipo.toUpperCase()} enviada por ${medio.toUpperCase()} al usuario ${email} sobre el fondo "${fondo}"`;

    // Simulación de envío (en real usarías AWS SNS o SES)
    console.log(mensaje);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: mensaje }),
    };

  } catch (error) {
    console.error('Error en notify:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Error interno en el servicio de notificación' }),
    };
  }
};
