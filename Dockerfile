FROM python:latest
RUN apt update 
RUN apt -y install git
RUN git clone https://github.com/IshtaarD/kuralabs_deployment_5
WORKDIR /kuralabs_deployment_5
RUN pip install -r requirements.txt
RUN pip install gunicorn
EXPOSE 8000
ENTRYPOINT python3 -m gunicorn -w 4 application:app -b 0.0.0.0:8000
