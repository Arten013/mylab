RESEARCH_DIR = $(HOME)/research
DOCKERFILE_DIR = $(RESEARCH_DIR)/mylab
DOCKERHUB_USR = atbell013
IMAGE = $(DOCKERHUB_USR)/mylab
REIKI_SRC_DIR = $(RESEARCH_DIR)/reikiset
REIKI_TAR_DIR = /root/home/reikiset
RES_SRC_DIR = $(RESEARCH_DIR)/results
RES_TAR_DIR = /root/home/results

build:
	docker-compose build
push:
	docker push $(IMAGE)

up:
	docker-compose up main bash
jupyter:
	docker-compose up main jupyter notebook
down:
	docker-compose down
