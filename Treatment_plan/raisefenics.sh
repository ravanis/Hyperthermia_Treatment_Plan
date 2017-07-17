# Quick way to start a FEniCS session using Docker through bash on Windows
CURDIR=$(pwd)
bash --login -i "./start.sh" \
                "cd $CURDIR; fenicsproject run"

