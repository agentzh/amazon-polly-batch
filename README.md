Name
====

amazon-polly-batch - convert large plain text files to MP3 files via Amazon Polly

Table of Contents
=================

* [Name](#name)
* [Synopsis](#synopsis)
* [Description](#description)
* [Installation](#installation)
* [TODO](#todo)
* [Author](#author)
* [Copyright & License](#copyright--license)

Synopsis
========

```bash
# Step 1: generate .docx from .pdf files using Adobe Export (which supports OCI).
# Step 2: generate .txt from .docx from Microsoft Word (ensure you use LF line breaks
# and UTF-8 encoding in the Word export configuration).

# Step 3: use tweak-txt.pl to tweak the .txt file automatically:

./tweak-txt.pl my-book.txt > my-book-new.txt

# Step 3: edit the tweaked .txt file for typos and stuff you don't need etc.
vi my-book-new.txt

# Step 4: generate SSML source file, my-book-new.ssml,
# from the tweaked and edited .txt file (using the "slow" voice speed,
# other possible speech rates are "x-slow", "medium", "fast", and "x-fast"):
./txt2ssml.pl -s slow my-book-new.txt > my-book-new.ssml

# Step 5: generate an MP3 file from the `.ssml` file:
./ssml2mp3.py -o my-book.mp3 --voice Salli my-book-new.ssml

# Step 6: (optional) set mp3 file metadata, need to install id3v2 first:
id3v2 -A 'Album Name' -t 'Song Title' -a 'Artist Name' -y 2017 -g 28 my-book.mp3

# Step 7: let's play the .mp3 file!
```

Description
===========

Amazon Polly is a text-to-speech service API which gives human-like voices of good quality. This
toolkit makes it easy to convert large volumes of text (like e-books) into audio books of the MP3
format.

The input plain text file for the `txt2ssml.pl` tool should use the following convention:

Each paragraph should be in its own separate line, no line breaks should be inserted in the middle
of a paragraph.

The `txt2ssml.pl` tool treats each non-empty line as a paragraph. A short-enough paragraph is treated
as a title. Empty lines are ignored and removed. Leading spaces and trailing spaces in each paragraph
are automatically removed. Successive spaces are squeezed into a single space.

The `txt2ssml.pl` tool understands the following special marks:

* ``VB`objects` `` interpretes the word `objects` as a simpel-tense verb and thus adjust the pronunciation accordingly.
* `Will` interprets the word `will` as a noun and thus change the pronunciation accordingly.

Below is a sample MP3 file generated from 2 small book sections:

http://openresty.org/download/audio/ib4.mp3

Installation
============

1. Install perl and python. On Ubuntu, for example, it is as easy as

    ```bash
    sudo apt-get install python python-pip perl
    ```

    or similarly, on Fedora:

    ```bash
    sudo dnf install python python-pip perl
    ```
2. Install the AWS SDK for Python:

    ```bash
    pip install boto3
    ```

    Configure the AWS credentials file in `~/.aws/credentials`.

    ```ini
    [default]
    aws_access_key_id = XXXXXXXXXXXXXXX
    aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXX

    [default]
    region=us-west-2
    ```

    You need to find out the access key ID and secret access key for your AWS account. Also please note that
    not every AWS region provides the Polly service. Check out the AWS official documentation on what regions
    do. For example, `us-west-2` does provide the Polly service while `us-west-1` doesn't.
3. Install `id3v2` if you want to modify the metadata of the resulting MP3 files:

    ```bash
    # For Ubuntu/Debian:
    sudo apt-get install id3v2

    # For Fedora:
    sudo dnf install id3v2
    ```

[Back to TOC](#table-of-contents)

TODO
====

* Add parallel jobs support to query the Amazon Polly web services with multiple concurrent
connections and queries.

[Back to TOC](#table-of-contents)

Author
======

Yichun Zhang <agentzh@gmail.com>

[Back to TOC](#table-of-contents)

Copyright & License
===================

Copyright (C) 2017 by Yichun Zhang, OpenResty Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)

