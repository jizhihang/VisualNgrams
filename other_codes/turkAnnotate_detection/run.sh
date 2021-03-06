#!/usr/bin/env sh
#
# Copyright 2008 Amazon Technologies, Inc.
# 
# Licensed under the Amazon Software License (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
# 
# http://aws.amazon.com/asl
# 
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and
# limitations under the License.

#categ='horse'
categ=$1;

#resdir=$MTURK_CMD_HOME/samples/object_detection;
resdir=$2;

#nummaxhits=$3;

label=$resdir/$categ 
input=$resdir/$categ.input
question=$resdir/$categ.question
properties=$resdir/$categ.properties

echo "run on category : $categ"

DIR=$(pwd);
cd $MTURK_CMD_HOME/bin

./loadHITs.sh -label $label -input $input -question $question -properties $properties -sandbox -maxhits 3 
#./loadHITs.sh -label $label -input $input -question $question -properties $properties -sandbox  

cd $DIR

