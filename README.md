# Achilles: Efficient TEE-Assisted BFT Consensus via Rollback Resilient Recovery

This is the accompanying code to the paper "DAMYSUS: Streamlined BFT
Consensus Leveraging Trusted Components" which was accepted to EuroSys
2022. A technical report is available
[here](https://github.com/vrahli/damysus/blob/main/doc/damysus-extended.pdf).

## Current status

The software is under ongoing development.

## Installing

To tests our protocols, we provide a Python script, called
`experiments.py`, as well as a `Dockerfile` to create a Docker
container. We use the
[Salticidae](https://github.com/Determinant/salticidae) library, which
is added here as git submodule.

### Salticidae

You won't need to follow this step if you are using our Docker
container, as it is done when building the container, and can jump to
the next (Python) section.
If you decide to install Salticidae locally, you will need git and cmake.
In which case, after cloning the repository you need to type this to initialize the
Salticidae git submodule:

`git submodule init`

followed by:

`git submodule update`

Salticidea has the following dependencies:

* CMake >= 3.9
* C++14
* libuv >= 1.10.0
* openssl >= 1.1.0

`sudo apt install cmake libuv1-dev libssl-dev`

Then, to instance Salticidae, type:
`(cd salticidae; cmake . -DCMAKE_INSTALL_PREFIX=.; make; make install)`

### Python

We use python version 3.8.10.  You will need python3-pip to install
the required modules.

The Python script relies on the following modules:
- subprocess
- pathlib
- matplotlib
- time
- math
- os
- glob
- datetime
- argparse
- enum
- json
- multiprocessing
- random
- shutil
- re

If you haven't installed those modules yet, run:

`python3 -m pip install subprocess pathlib matplotlib time math os glob datetime argparse enum json multiprocessing random shutil re`

### Docker

To run the experiments within Docker containers, you need to have
installed Docker on your machine. This
[page](https://docs.docker.com/engine/install/) explains how to
install Docker. In particular follow the following
[instructions](https://docs.docker.com/engine/install/linux-postinstall/)
so that you can run Docker as a non-root user.

You then need to create the container by typing the following command at the root of the project:

`docker build -t damysus .`

This will create a container called `damysus`.

We use `jq` to extract the IP addresses of Docker containers, so make
sure to install that too.



## Usage

### Default command

We explain the various options our Python scripts provides. You will
run commands of the following form, followed by various options
explained below:

`python3 experiments.py --docker --pall`

### Options

In addition, you can use the following options to change some of the parameters:
- `--docker` to run the nodes within Docker containers
- `--repeats n` to change the number of repeats per experiment to `n`
- `--payload n` to change the payload size to `n`
- `--faults a,b,c` to run the experiments for f=a, f=b, etc.
- `--pall` is to run all protocols, instead you can use `--p1` up to `--p6`
    - `--p1`: base protocol, i.e., HotStuff
    - `--p2`: Damysus-C (checker only)
    - `--p3`: Damysus-A (accumulator only)
    - `--p4`: Damysus
    - `--p5`: chained base protocol, i.e., chained HotStuff
    - `--p6`: chained Damysus
- `--netlat n` to change the network latency to `n`ms
- `--clients1 n` to change the number of clients to `n` for the non-chained protocols
- `--clients2 n` to change the number of clients to `n` for the chained protocols
- `--tvl` to compute a "max throughput" graph
- `--onecore` to compute the code using one core only
- `--hw` to run SGX in hardware mode
    + this option cannot be used with docker
    + it requires the sgxsdk to be installed here: `/opt/intel/sgxsdk`, which can be achieved following the steps in the Dockerfile
    + it requires installing Salticidae following the steps mentioned above
- `--cluster` to run the nodes remotely (see the [Cluster](###Cluster) section for more information)
    + this option will automatically use Docker containers
    + it currently cannot user SGX in hardware mode
    + it currently cannot be combined with `--tvl`

### Examples

For example, if you run:

`python3 experiments.py --docker --p1 --p2 --repeats 2 --faults 1`

then you will run the replicas within Docker containers (`--docker`),
test the base protocol (`--p1`) and Damysus-C (`--p2`), repeat the
experiments twice (`--repeats 2`), and test for f=1 (`--faults 1`).

If your run:

`python3 experiments.py --docker --pall --repeats 10 --faults 1,2,4`

then you will run the replicas within Docker containers (`--docker`),
test all protocols (`--pall`), repeat the experiments 10 times
(`--repeats 10`), and test for f=1, f=2, and f=4 (`--faults 1,2,4`)

### Recommended experiments

We recommend that you try the following experiments. Note that 100
repetitions will take quite a long time. You can start with a smaller
value between 2 and 10 to get an idea of the results you will obtain.

- Run all protocols with a 0ms network latency, 0B payloads, for
  f=1,2,4,10, with 100 repetitions per experiment (consider
  using less repetitions)

`python3 experiments.py --docker --pall --netlat 0 --payload 0 --faults 1,2,4,10 --repeats 100`

- Run all protocols with a 100ms network latency, 256B payloads, for
  f=1,2,4,10, with 100 repetitions per experiment (consider
  using less repetitions)

`python3 experiments.py --docker --pall --netlat 100 --payload 256 --faults 1,2,4,10 --repeats 100`




### AWS

The AWS experiments are more adhoc. They require images to already
exist in the regions. Change `regions` to select the regions you want
to use.  Then run something like this (as before with the  `--aws`
option):
  ```
    python3 experiments.py --aws --p1 --repeats 1 --faults 1
  ```

In case something goes wrong, you can stop all instances as follows:
  ```
    python3 experiments.py --stop
  ```

To debug on AWS, try something like this:
  ```
    python3 experiments.py --launch 1
    python3 experiments.py --copy XXX
  ```
to launch an instance at some address XXX, which will be printed by
the first command; then copy all files to the instance. After that you
can ssh the address, and do whatever you want there.



