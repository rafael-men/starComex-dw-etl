# StarComex DW ETL

## Instruções para execução

Pré-requisitos:

- Ter o Python instalado
- Ter o Java 17 instalado
- Possuir o [driver do Postgres](https://jdbc.postgresql.org/download/)

Execução

1. Crie e inicialize um ambiente virtual Python (opcional):

```sh
python -m venv venv
source venv/bin/activate # Em Linux
venv/Scripts/activate    # Em Windows
```

2. Instale as dependências:

```sh
pip install -r requirements.txt
```

3. Defina as variáveis de ambiente de ambiente necessárias:

```ini
# .env
DB_HOST     = "host do banco de dados"
DB_USER     = "usuário do banco de dados"
DB_PASSWORD = "senha do usuário"
DB_NAME     = "nome do banco de dados"
POSTGRES_DRIVER_PATH = "caminho absoluto para o driver do Postgres"
```

4. Execute o projeto:

```sh
python etl_starcomex/main.py 
```
