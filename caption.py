import os
import subprocess
import sys

from pywhispercpp.model import Model
from pywhispercpp.utils import *

filename = 'test.mp3'
	
n_t = 4
model_name = 'base.en' #tiny.en,tiny,base,base.en,small,small.en
spl_on_word = True
char_len = 1
greedy_search = True
token_TS = True
save = True
save_path = filename[:-3] + 'srt'

if len(sys.argv)>1:
  filename = sys.argv[1]
  save_path = sys.argv[2]
  model_name = sys.argv[3]
  n_t = int(sys.argv[4])

# print(sys.argv)

home = os.path.expanduser('~')
path = os.path.join(os.getcwd(), filename)
  

# print(path)

model = Model(model_name,
              models_dir = 'models',
            params_sampling_strategy=int(not greedy_search), 
            n_threads=1
            )
segments = model.transcribe(path,
                            n_threads=n_t,
                            split_on_word = spl_on_word,
                            max_len=1,
                            token_timestamps = token_TS
                            )
print(len(segments), ' tokens saved')
#for segment in segments:
#    print(segment.text)

if save:
    output_srt(segments, save_path)


'''
# Construct the shell command
shell_command = f"pwcpp {path} -m {model_name} --output-srt\
                    --n_threads {n_threads} --max_len 20\
                    --split_on_word true"

# Run the shell command
subprocess.run(shell_command, shell=True)
'''
