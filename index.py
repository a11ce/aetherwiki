import glob
import os
import frontmatter  # pip install python-frontmatter
from collections import defaultdict

order = [
    "Countries", "Events", "Groups", "Companies", "Locations", "Technology",
    "Politics", "Other"
]

cats = defaultdict(lambda: defaultdict(list))

for md in glob.glob("md-src/*.md"):
    name = os.path.basename(md)

    if "index" in md:
        continue

    meta = frontmatter.load(md)
    title = meta["title"]
    cat = meta.get("tag", "Other")
    if "." in cat:
        main, sub = cat.split(".")
    else:
        main, sub = cat, None
    cats[main][sub].append((title, name))

print("---")
print("title: \"Index\"")
print("---\n")
print("""<style>
    .cols {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(10em, 1fr));
      gap: 2em;
      row-gap: 0.5em;

      margin: 0;
      padding: 0
    }
    
    .col {
      break-inside: avoid
    }
    
    h2 {
      text-decoration: underline
    }
    
    h2,
    h3 {
      margin-bottom: 0
    }
    </style>
    """)


def printCat(main):
    print(f"::: {{.col}}\n## {main}")
    for page, link in sorted(cats[main][None]):
        print(f"- [[{page}|{link}]]")

    for sub in sorted(s for s in cats[main] if s is not None):
        print(f"\n### {sub}")
        for page, link in sorted(cats[main][sub]):
            print(f"- [[{page}|{link}]]")
    print(":::\n")


print("::: {.cols}")

for main in order:
    printCat(main)

for main in sorted(cats, key=str.lower):
    if main not in order:
        printCat(main)

print("\n:::")
