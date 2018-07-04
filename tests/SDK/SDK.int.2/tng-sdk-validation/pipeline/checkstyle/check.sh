#!/bin/bash
mkdir -p reports
echo "Checking style..."
docker run -i --rm registry.sonata-nfv.eu:5000/tng-sdk-validation pycodestyle --exclude .eggs . > reports/checkstyle-pep8.txt
echo "Checkstyle result:"
cat reports/checkstyle-pep8.txt
echo "Done"