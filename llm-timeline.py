import openai
import secret
from tqdm import tqdm

client = openai.OpenAI(api_key=secret.openAIKey)


def summarize(line):
    response = client.responses.create(
        model="gpt-4.1-mini",
        input=[{
            "role":
            "system",
            "content": [{
                "type":
                "input_text",
                "text":
                "You are looking at entries in a fictional historical timeline. For each entry, respond with `year: summary`. \n\nThe summary should be short and only cover what happened in that specific year. Do not add commentary. Assume later events will be covered later.\n\nBe concise. For example, say \"X invents Y\" instead of \"Y was invented by X\".\n\nIf the entry does not describe an event taking place in a specific year, say `false`. Years will always range from 0 to 999. If the entry describes events in multiple years, respond with one per line. If the entry contains a date range, respond with a line for the start and a line for the end."
            }]
        }, {
            "role": "user",
            "content": [{
                "type": "input_text",
                "text": line
            }]
        }],
        text={"format": {
            "type": "text"
        }},
        reasoning={},
        tools=[],
        temperature=0.66,
        max_output_tokens=10000,
        top_p=1,
    )
    return response.output_text


with open('auto-timeline.txt', 'r') as f:
    out = ""
    for line in tqdm(f):
        s = summarize(line)
        if s != 'false':
            out += "\n" + summarize(line)

for line in sorted(out.splitlines()):
    print(f"- {line}")
