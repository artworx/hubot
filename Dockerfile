FROM node:0.10-onbuild

EXPOSE 8080

CMD bin/hubot -a slack
