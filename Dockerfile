FROM python:3.12-slim as BUILD
WORKDIR /app

#install the build dependencies and remove unwanted files
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists

#copy req to container
COPY requirements.txt ./

#upgrade pip and install req to specific folder
RUN pip install --upgrade pip && pip install --no-cache-dir --prefix=/install -r requirements.txt


#Stage - 2 : Runtime
FROM python:3.12-slim

#Explicitly add group and user
RUN groupadd -r pythonapp && \
    useradd -r -g pythonapp pythonapp

WORKDIR /app


COPY --from=BUILD /install /usr/local/

COPY . .

#change owner
RUN chown -R pythonapp:pythonapp /app

#switch to non root user
USER pythonapp
EXPOSE 8502
CMD ["streamlit", "run", "app.py"]
