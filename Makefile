.PHONY: install setup-dbt run-dbt test-dbt check-env

install:
	python3 -m venv venv && \
	. venv/bin/activate && \
	pip install -r requirements.txt

setup-dbt:
	. venv/bin/activate && \
	dbt deps --project-dir arco_analytics

run-dbt:
	. venv/bin/activate && \
	dbt run --project-dir arco_analytics --profiles-dir arco_analytics

test-dbt:
	. venv/bin/activate && \
	dbt test --project-dir arco_analytics --profiles-dir arco_analytics

build-dbt:
	. venv/bin/activate && \
	dbt build --project-dir arco_analytics --profiles-dir arco_analytics
