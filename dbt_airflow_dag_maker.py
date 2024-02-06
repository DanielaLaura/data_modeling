import os
import pendulum
import json
import yaml
from airflow import DAG
from airflow.operators,bash import BashOperator
from airflow.utils.dates import timedelta
from operator import itemgetter

HOME_DIR = os.path.dirname(os.path.abspath(__file__))
partition = "{{ (data_interval_start).strftime('%Y-%m-%d') }}"

default_args = {
    "owner": "dbt",
    "catchup": False,
    "start_date": pendulum.today("UTC").add(days=-1),
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5)

}

def load_file(path: str, config_type: str) -> dict:
    if config_type not in ("json", "yaml"):
        raise ValueError(" wrong config_type")
    with open(path) as f:
        return json.load(f)  if config_type == "json" else yaml.safe_load(f)

# creates run and test tasks for each dbt model configured
def make_dbt_task(node, dbt_verb, dag_node, target, var, exclude_flag) -> BashOperator:

    model=node.split(".")[2]
    dbt_task = None
    if dbt_verb=="run":
        dbt_task=BashOperator(
            task_id = node,
            bash_command= f""" .\dbt_env\Scripts\/activate; dbt {dbt_verb} --select {model} -t {target}"""
            if not var
            else f""" .\dbt_env\Scripts\/activate; dbt {dbt_verb} --select {model} --vars {var} -t {target}""",
            dag=dag_node
        )
    elif dbt_verb=="test":
        node_test = node.replace("model","test")
        dbt_task = BashOperator(
            task_id=node_test,
            bash_command=f""" .\dbt_env\Scripts\/activate; dbt {dbt_verb} --select {model} --exclude {exclude_flag} -t {target}""",
            dag=dag_node
        )
    return dbt_task

manifest = load_file(path =f"{HOME_DIR}/target/manifest.json", config_type="json")
model_run_config = load_file(path =f"{HOME_DIR}/target/config_dbt_models.yml", config_type="yaml")

# build run and test airflow tasks (corresponding to each dbt model)
for node_type, model_name, node_name in [(node.split(".")[0], node.split(".")[2], node) for node in manifest["nodes"].keys()]:
    if node_type=="model" and model_name in (node for node in model_run_config["configuration"]):
        schedule, target, variable, exclude_flag= itemgetter("schedule", "target", "var", "exclude_flag")(model_run_config["configuration"][model_name])
        schedule_int = f"0 {schedule} * * *"
        model_var = f"'{{{variable}: {partition}}}'" if variable!= "None" else None
        globals()[model_name] = (dag := DAG(model_name, schedule_interva=schedule_int, default_args = default_args))
        make_dbt_task(node_name, "run", dag, target, model_var, exclude_flag) >> make_dbt_task(node_name, "test", dag, target, model_var, exclude_flag)
    else:
        pass