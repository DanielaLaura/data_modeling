Welcome to this data modeling - dbt project!

### SQL tests
Sql code can be found at: 
https://github.com/DanielaLaura/data_modeling/blob/main/SQL_Test__Coveo.pdf
### About the data models:

- There are 2 versions of "rpt_ml_search_model_obs" model, which is the requested data model that would make the reporting easier. 
- These models, in models/export/ folder, are data models ready to be consumed by the BI reporting tool.
- The first version - "rpt_ml_search_model_obs"  - is built directly on the dimension tables made available by the ML team
- The second version -  "rpt_ml_search_model_obs_v2" - is built based on an intermediary table (int_search_clicks) that joins clicks and search dimension table, and two fact tables - one for search metrics and one for top N metrics; this was done in order to have a layer of defense on data quality/outliers, apply DRY concept to analytics code and the flexibility to add more metrics without the need to add more code to the final model.
- The two versions of this model were presented in order to  discuss the differences between them.


### Using the starter project

Try running the following commands:
- dbt run -m fct_search_metrics -t dev --vars "{verbose: True, unit_test: false}”
- dbt test -m fct_search_metrics -t dev --vars "{verbose: True, unit_test: false}”


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
