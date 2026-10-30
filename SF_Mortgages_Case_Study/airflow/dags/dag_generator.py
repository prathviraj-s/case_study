import os
import glob
import yaml

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook


CONFIG_DIR = os.path.join(os.path.dirname(__file__), "config")

DBT_DIR = "/opt/airflow/curation"
SNOWFLAKE_CONN = "snowflake_mortgage"


def load_yaml(path):
    with open(path, "r") as f:
        return yaml.safe_load(f)


def check_bronze(config, **context):

    hook = SnowflakeHook(
        snowflake_conn_id=SNOWFLAKE_CONN
    )

    partitions = {}

    for table in config["bronze_tables"]:

        result = hook.get_first(
            f"SELECT MAX(LOAD_TIMESTAMP) FROM {table}"
        )

        if not result or result[0] is None:
            raise Exception(f"No data available in {table}")

        partitions[table] = str(result[0])

    context["ti"].xcom_push(
        key="partitions",
        value=partitions
    )


def update_checkpoint(config, **context):

    hook = SnowflakeHook(
        snowflake_conn_id=SNOWFLAKE_CONN
    )

    partitions = context["ti"].xcom_pull(
        task_ids="dag_exec_check",
        key="partitions"
    )

    checkpoint_table = config["checkpoint"]["table"]

    for source, partition in partitions.items():

        sql = f"""
        MERGE INTO {checkpoint_table} t
        USING (
            SELECT
                %s DAG_ID,
                %s SOURCE_NAME,
                TO_TIMESTAMP_NTZ(%s) LAST_PARTITION
        ) s

        ON t.DAG_ID = s.DAG_ID
        AND t.SOURCE_NAME = s.SOURCE_NAME

        WHEN MATCHED THEN UPDATE SET
            LAST_SUCCESS_PARTITION = s.LAST_PARTITION,
            STATUS = 'SUCCESS',
            UPDATED_AT = CURRENT_TIMESTAMP()

        WHEN NOT MATCHED THEN INSERT
            (
                DAG_ID,
                SOURCE_NAME,
                LAST_SUCCESS_PARTITION,
                STATUS,
                UPDATED_AT
            )
        VALUES
            (
                s.DAG_ID,
                s.SOURCE_NAME,
                s.LAST_PARTITION,
                'SUCCESS',
                CURRENT_TIMESTAMP()
            )
        """

        hook.run(
            sql,
            parameters=(
                config["dag_id"],
                source,
                partition
            )
        )


def create_dag(config):

    alerting = config.get("alerting", {})

    with DAG(
        dag_id=config["dag_id"],
        schedule=config.get("schedule"),
        catchup=False,
        default_args={
            "retries": 2,
            "email": alerting.get("email", []),
            "email_on_failure": alerting.get("enabled", False)
        }
    ) as dag:

        # ---------------------------------
        # 1. Dependency check
        # ---------------------------------

        if config["dependency"]["type"] == "bronze":

            dag_exec_check = PythonOperator(
                task_id="dag_exec_check",
                python_callable=check_bronze,
                op_kwargs={"config": config}
            )

        else:

            dag_exec_check = ExternalTaskSensor(
                task_id="dag_exec_check",
                external_dag_id=config["dependency"]["dag_id"],
                external_task_id=None,
                allowed_states=["success"],
                failed_states=["failed"],
                mode="reschedule",
                poke_interval=60,
                timeout=3600
            )

        # ---------------------------------
        # 2. Run dbt model
        # ---------------------------------

        data_load = BashOperator(
            task_id="data_load",
            bash_command=(
                f"cd {DBT_DIR} && "
                f"dbt run --select {config['dbt_model']}"
            )
        )

        # ---------------------------------
        # 3. Run dbt tests
        # ---------------------------------

        dbt_test = BashOperator(
            task_id="dbt_test",
            bash_command=(
                f"cd {DBT_DIR} && "
                f"dbt test --select {config['dbt_model']}"
            )
        )

        # ---------------------------------
        # 4. Dependencies
        # ---------------------------------

        if config["checkpoint"]["enabled"]:

            checkpoint = PythonOperator(
                task_id="checkpoint_update",
                python_callable=update_checkpoint,
                op_kwargs={"config": config}
            )

            dag_exec_check >> data_load >> dbt_test >> checkpoint

        else:

            dag_exec_check >> data_load >> dbt_test

        return dag


# -----------------------------------------
# Generate DAGs from YAML files
# -----------------------------------------

for file in glob.glob(
    os.path.join(CONFIG_DIR, "**/*.yml"),
    recursive=True
):

    config = load_yaml(file)

    globals()[config["dag_id"]] = create_dag(config)