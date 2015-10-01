FROM node:0.10-onbuild

EXPOSE 80

CMD bin/hubot -a slack
