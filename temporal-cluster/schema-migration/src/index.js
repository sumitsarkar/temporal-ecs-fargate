const shell = require('shelljs');
const environment = require('./env')


const respondAfterShellExecution = (shellExecution, callback) => {
  if (shellExecution.code !== 0) {
    shell.echo('Error: Command failed');
    callback(null, {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': false,
      },
      body: JSON.stringify({
        stacktrace: shellExecution.stderr,
      }),
    })
  } else {
    callback(null, {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': false,
      },
      body: JSON.stringify({
        stacktrace: shellExecution.stdout,
      }),
    })
  }
}


module.exports.handler = async (event, context, callback) => {
  try {
    let requestData
    if (typeof event === "string") {
      requestData = JSON.parse(event.body)
    } else {
      requestData = event
    }

    if (requestData.eventType === 'migrate') {
      // Set the shell Environment Variable

      Object.keys(environment).forEach(key => {
        shell.env[key] = environment[key]
      })
      const shellExecution = shell.exec("./scripts/sql-setup.sh")
      respondAfterShellExecution(shellExecution, callback)
    } else if (requestData.eventType === 'createNamespace') {
      if (requestData.name === undefined || requestData.name.trim().length < 5) {
        callback(null, {
          statusCode: 400,
          headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials': false,
          },
          body: JSON.stringify({
            message: "You must specify at least a 5 character name for the namespace",
          }),
        })
      } else {
        const namespace = requestData.name
        Object.keys(environment).forEach(key => {
          shell.env[key] = environment[key]
        })
        shell.env['NAMESPACE_NAME'] = namespace
        const shellExecution = shell.exec("./scripts/create-namespace.sh")
        respondAfterShellExecution(shellExecution, callback)
      }
    } else {
      callback(null, {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Credentials': false,
        },
        body: JSON.stringify({
          message: "Unsupported event type",
        }),
      })
    }
  } catch (e) {
    console.log(e)
    callback(null, {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': false,
      },
      body: JSON.stringify({
        message: `Error in running migration!`,
        errors: e.errors,
      }),
    })
  }
}
