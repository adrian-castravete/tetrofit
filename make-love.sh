#!/bin/bash

zip -9r tetrofit.`date +%Y%m%d%H%M`.love . -x*.swp -xage-project/* -xconcept/* -x.git* -x*.love
