---
name: fetch-x-post-as-markdown
description: Retrieve an X/Twitter post as markdown when direct browser/page fetches are JS-heavy or blocked.
---

Use this when a user wants the contents of an X/Twitter URL in markdown or plain text.

## When to use
- User asks to fetch an X/Twitter post/thread/article as markdown
- Direct HTML fetch only returns the JS shell
- Browser automation is unavailable or blocked

## Workflow
1. Try the simplest mirror first with `r.jina.ai`:
   - Convert the target URL to:
     - `https://r.jina.ai/http://x.com/...`
     - or more generally `https://r.jina.ai/http://<original-host-and-path>`
   - Fetch it with `requests` or `curl`.
2. If the original X URL is a tweet that expands into an article/conversation, the `r.jina.ai` result may already contain the useful markdown under `Markdown Content:`.
3. Save the returned markdown to a `.md` file and deliver that file to the user if requested.
4. If needed, inspect `publish.x.com/oembed?url=<tweet-url>` to confirm author/title metadata, but note that oEmbed may contain only partial content.

## Example
```python
import requests, pathlib
url = 'https://r.jina.ai/http://x.com/wangray/status/2043334390185705598'
text = requests.get(url, timeout=60, headers={'User-Agent': 'Mozilla/5.0'}).text
path = pathlib.Path('/tmp/x-post.md')
path.write_text(text, encoding='utf-8')
print(path)
```

## Notes
- Direct `requests.get('https://x.com/...')` often returns only the app shell and no useful text.
- `publish.x.com/oembed` is useful for metadata validation but frequently omits the full post/article body.
- Alternate mirrors like Nitter/fxtwitter/fixupx/vxtwitter may redirect, challenge, or fail; use them only as fallback diagnostics.

## Verification
- Confirm the output includes a title and `Markdown Content:` block.
- Spot-check that the markdown contains the expected text from the post, not just login/signup boilerplate.
