from app.config import AppConfig
from app.domain.customer import Customer
from app.infra.db.databricks_client import DatabricksSQLClient
from app.repositories.customer_repository import CustomerRepository
from typing import List, Optional

class CustomerRepositoryImpl(CustomerRepository):
    def __init__(self, db_client: DatabricksSQLClient):
        self.db = db_client
        self.table = f"{AppConfig.get_catalog()}.{AppConfig.get_schema_publico_alvo()}.clientes"

    def get_by_cpf_cnpj(self, cpf_cnpj: str) -> Optional[Customer]:
        sql = f"SELECT * FROM {self.table} WHERE cpf_cnpj = '{cpf_cnpj}'"
        data = self.db.execute_query(sql)
        if not data:
            return None
        row = data[0]
        return Customer(
            cpf_cnpj=row[0], nome=row[1], tipo_pessoa=row[2],
            segmento=row[3], idade=row[4], uf=row[5], cidade=row[6],
            agencia_principal=row[7], conta_principal=row[8], email=row[9],
            telefone_ddd=row[10], telefone_numero=row[11],
            data_abertura_conta=str(row[12]) if row[12] else None
        )

    def list_by_segment(self, segmento: str, limit: int = 100) -> List[Customer]:
        sql = f"SELECT * FROM {self.table} WHERE segmento = '{segmento}' LIMIT {limit}"
        data = self.db.execute_query(sql)
        return [
            Customer(
                cpf_cnpj=r[0], nome=r[1], tipo_pessoa=r[2],
                segmento=r[3], idade=r[4], uf=r[5], cidade=r[6],
                agencia_principal=r[7], conta_principal=r[8], email=r[9],
                telefone_ddd=r[10], telefone_numero=r[11],
                data_abertura_conta=str(r[12]) if r[12] else None
            ) for r in data
        ]
