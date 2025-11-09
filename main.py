# Para instalar dependencias:
# pip install fastapi uvicorn boto3

# Para iniciar el servicio:
# uvicorn main:app --reload --host 0.0.0.0 --port 8000

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import boto3
import json
from botocore.exceptions import NoCredentialsError, ClientError

app = FastAPI()


bucket_name = "scm-0112-so"  

      


s3 = boto3.client("s3")


class Item(BaseModel):
    name: str = "Mateo"
    cedula: str = "1020223389"
    edad: int = 20


@app.get("/")
def read_root():
    return {"message": "Universidad EIA"}


@app.get("/items/{item_id}")
def read_item(item_id: int, query: str = None):
    return {"item_id": item_id, "query": query}


@app.post("/insert/")
def create_item(item: Item):
    try:
        file_key = f"usuarios/{item.cedula}.json"
   
        json_data = json.dumps(item.dict(), indent=4)

       
        s3.put_object(
            Bucket=bucket_name,
            Key=file_key,
            Body=json_data,
            ContentType="application/json"
        )

        return {
            "message": "Datos guardados correctamente en S3"
        }

    except NoCredentialsError:
        raise HTTPException(status_code=500, detail="No se encontraron credenciales de AWS")
    except ClientError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")
