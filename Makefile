restart:
	docker-compose rm -f zammad-railsserver || true
	docker rmi zammad-docker-compose_zammad-railsserver || true
	docker-compose up


nuke:
	docker-compose down
	docker-compose images -q |  xargs docker rmi -f


total-nuke:
	docker-compose down -v
	docker-compose images -q |  xargs docker rmi -f