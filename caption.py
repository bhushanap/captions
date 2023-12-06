import os
import subprocess

from pywhispercpp.model import Model
from pywhispercpp.utils import *



n_t = 4
filename = 'test2.m4a'
path = os.path.join(os.path.expanduser('~'), 'Downloads', filename)
model_name = 'base.en' #tiny.en,tiny,base,base.en,small,small.en
spl_on_word = True
char_len = 10
greedy_search = True
token_TS = True
save = True
save_path = filename[:-3] + 'srt'

print(path)

model = Model(model_name,
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
