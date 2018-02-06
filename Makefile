exec:
	docker exec -it kylin bash

run:
	docker run -itd --name kylin -p 7070:7070 -v `pwd`/logs:/usr/local/kylin/logs --add-host="MASTER-NODE-HOSTNAME:10.1.2.48" --add-host="sandbox.hortonworks.com:10.1.2.48" kylin:2.2.0

build:
	docker build -t kylin:2.2.0 .

clean:
	docker stop kylin && docker rm kylin
	docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi >/dev/null 2>&1
