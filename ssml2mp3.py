#!/usr/bin/env python

from boto3 import Session
from botocore.exceptions import BotoCoreError, ClientError
from contextlib import closing
import argparse
import os
import sys

import subprocess
from tempfile import gettempdir

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('-o', metavar='MP3-FILE', type=str, default="a.mp3",
                    help='the output .mp3 file name')
parser.add_argument('--voice', metavar='VOICE', default="Salli",
                    help='the AWS Polly voice name. default to Salli')
parser.add_argument('infile', metavar='SSML-FILE', type=str,
                    help='the SSML input file')

args = parser.parse_args()

outfile = args.o

# Create a client using the credentials and region defined in the [adminuser]
# section of the AWS credentials file (~/.aws/credentials).
session = Session() #profile_name="adminuser")
polly = session.client("polly")

voice = args.voice or "Salli"
#voice = "Joanna"

infile = args.infile
index = 1

pieces = []
with open(infile, "rb") as f:
    pieces = [l for l in (line.strip() for line in f) if l]

with open(outfile, "wb") as out:
    i = index
    for piece in pieces:
        print "piece %d: %s" % (i, piece)
        try:
            # Request speech synthesis
            response = polly.synthesize_speech(Text=piece, TextType="ssml", OutputFormat="mp3",
                 VoiceId=voice)
        except (BotoCoreError, ClientError) as error:
            # The service returned an error, exit gracefully
            print(error)
            sys.exit(-1)

        # Access the audio stream from the response
        if "AudioStream" in response:
            # Note: Closing the stream is important as the service throttles on the
            # number of parallel connections. Here we are using contextlib.closing to
            # ensure the close method of the stream object will be called automatically
            # at the end of the with statement's scope.
            with closing(response["AudioStream"]) as stream:
                try:
                    # Open a file for writing the output as a binary stream
                    out.write(stream.read())
                except IOError as error:
                    # Could not write to file, exit gracefully
                    print(error)
                    sys.exit(-1)

        else:
               # The response didn't contain audio data, exit gracefully
            print("Could not stream audio")
            sys.exit(-1)

        i = i + 1

        # Play the audio using the platform's default player
        # the following works on Mac and Linux. (Darwin = mac, xdg-open = linux).
        #opener = "open" if sys.platform == "darwin" else "xdg-open"
        #subprocess.call([opener, output])
