import os
import openai
import re

openai.api_key = os.environ.get("OPENAI_API_KEY")

def extract_variables(prompt: str):
    return list(set(re.findall(r"{{(.*?)}}", prompt)))

def generate_prompt_and_parameters(description: str):
    system_msg = "Eres un generador de prompts experto para modelos LLM. Dado un problema, debes devolver un prompt reutilizable con parámetros entre dobles llaves {{}}."
    user_msg = f"""
        Problema: {description}

        Devuélveme solo el prompt reutilizable. Por ejemplo: 
        'Analiza el sentimiento de este texto: {{texto}} y clasifícalo como positivo, negativo o neutral.'
    """

    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": system_msg},
            {"role": "user", "content": user_msg}
        ],
        temperature=0.5,
        max_tokens=500
    )

    generated_prompt = response["choices"][0]["message"]["content"].strip()
    variables = extract_variables(generated_prompt)

    return {
        "prompt": generated_prompt,
        "variables": variables
    }
