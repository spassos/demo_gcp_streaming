import time
import json
from google.cloud import pubsub_v1
from faker import Faker

# Configurações do Pub/Sub
project_id = "<project_id>"
topic_id = "demo-topic"

# Inicializando Publisher
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, topic_id)

# Inicializando Faker para gerar dados sintéticos
fake = Faker()

def publish_message(publisher, topic_path, message):
    # Publica a mensagem como JSON
    future = publisher.publish(topic_path, json.dumps(message).encode("utf-8"))
    print(f"Publicado {message} ao tópico {topic_path}")
    return future.result()

def generate_synthetic_data():
    # Gera dados fictícios para publicação
    return {
        "timestamp": fake.iso8601(),
        "message": fake.sentence()
    }

def main():
    try:
        while True:
            # Gerar dados e publicar
            data = generate_synthetic_data()
            publish_message(publisher, topic_path, data)
            # Espera 1 segundo antes de gerar outra mensagem
            time.sleep(1)
    except KeyboardInterrupt:
        print("Processo interrompido.")

if __name__ == "__main__":
    main()
