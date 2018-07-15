RESEARCH_DIR = $(HOME)/research
DOCKERFILE_DIR = $(RESEARCH_DIR)/mylab
DOCKERHUB_USR = atbell013
IMAGE = $(DOCKERHUB_USR)/mylab
REIKI_SRC_DIR = $(RESEARCH_DIR)/reikiset
REIKI_TAR_DIR = /root/home/reikiset
RES_SRC_DIR = $(RESEARCH_DIR)/results
RES_TAR_DIR = /root/home/results
N4J_SRC_DIR = $(RESEARCH_DIR)/neo4j
N4J_TAR_DIR = /var/lib/neo4j

build:
	docker-compose build
push:
	docker push $(IMAGE)

run:
	docker-compose run main bash
	docker-compose down
