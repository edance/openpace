from garmin_fit_sdk import Decoder, Stream
from datetime import date, datetime
import json

def serializer(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError ("Type %s not serializable" % type(obj))

def decode(file_path):
  stream = Stream.from_file(file_path)
  decoder = Decoder(stream)
  messages, errors = decoder.read()

  return json.dumps(messages, default=serializer)
