import logging
import os
import azure.functions as func
import requests
# This is for application-insights to trace the http calls between functions
from opencensus.extension.azure.functions import OpenCensusExtension
from opencensus.trace import config_integration
config_integration.trace_integrations(['requests'])
OpenCensusExtension.configure()

app = func.FunctionApp()

@app.function_name(name="HttpTrigger1")
@app.route(route="hello")
def test_function(req: func.HttpRequest) -> func.HttpResponse:
     logging.info('Python HTTP trigger function processed a request.')

     name = req.params.get('name')
     if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

     if name:
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.")
     else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )


@app.function_name(name="vnettest")
@app.route(route="test")
def test_function(req: func.HttpRequest, context) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    private_function = os.getenv("PRIVATE_FUNCTION_ENDPOINT")

    with context.tracer.span("parent"):
        response = requests.get(url=private_function)
        logging.info(response.text)
        return func.HttpResponse(f"Response from private function: {response.text}")
