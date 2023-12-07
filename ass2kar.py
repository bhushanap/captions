import re
from pyonfx import *
import sys

def convert_to_karaoke(input_str):
    # Regular expression to extract timing and text information
    regex = r'(\d+:\d+:\d+\.\d+),(\d+:\d+:\d+\.\d+),.*?,,.*?,,(.*?)\n'
    
    # Find all matches using the regex
    matches = re.findall(regex, input_str)
    
    # Convert matches to karaoke format
    totFlag = 0
    byTime =  True
    byGroup = True
    bySize = True
    if byTime:
        totFlag+=1
    if bySize:
        totFlag+=1
    if byGroup:
        totFlag+=1
    group = 4
    size = 15
    time_diff = 4
    prev_time = 0
    prev_idx = 0
    lines = []
    words = []
    for idx, match in enumerate(matches):
        start_time, end_time, text = match
        etime = Convert.time(end_time)
        stime = Convert.time(start_time)
        dur = int((etime-stime)/10) #centisecond
        length = 0
        for word in words:
            length += len(word[0])
        nextFlag = 0
        
        if byTime and stime-time_diff*1000>prev_time:
            nextFlag+=1
        if bySize and length>size:
            nextFlag+=1
        if byGroup and idx-prev_idx>=group:
            nextFlag+=1
        if nextFlag>totFlag-2 and nextFlag>0:
            lines.append(f'Dialogue: 3,{Convert.time(prev_time)},{start_time},Romaji,,0,0,400,,' \
                        + ''.join([f'{{\\k{word[1]}}}{word[0]}' for word in words]))
            #print(words, length, idx-prev_idx, (stime-prev_time)/1000)
            prev_time = stime
            prev_idx = idx
            words = []
            # print(start_time)
        # if byTime:
        #     if stime-time_diff*1000>prev_time:
        #         lines.append(f'Dialogue: 3,{Convert.time(prev_time)},{start_time},Romaji,,0,0,400,,' \
        #                 + ''.join([f'{{\\k{word[1]}}}{word[0]}' for word in words]))

        #         prev_time = stime
        #         prev_idx = idx
        #         print(words)
        #         words = []
        #         print(start_time)
        # else:
        #     length = 0
        #     for word in words:
        #         length += len(word[0])
        #     if idx%group==0 or length>size:
                
                
        
        words.append((text,dur))
    
    # print(lines)
        
        
        # karaoke_lines.append(f'Dialogue: {idx+3},{start_time},{end_time},Default,,0,0,0,,' + ''.join([f'{{\\k{len(word)}}}{word}' for word in text.split()]))
    
    return lines

# Specify the path to your .ass file
if len(sys.argv)>1:
    ass_path = sys.argv[1]
    cfg_path = sys.argv[2]

save_path = 'tmp.ass'


# Read lines starting with 'Dialogue:' from the file
with open(ass_path, 'r', encoding='utf-8') as file:
    dialogue_lines = [line.strip() for line in file if line.startswith('Dialogue:')]

#print(dialogue_lines)
# toRemove = len(dialogue_lines)

# Convert the list of lines to a single string
dialogue_string = '\n'.join(dialogue_lines)

# Print or use the dialogue_string as needed


karaoke_output = convert_to_karaoke(dialogue_string)

with open(cfg_path, 'r', encoding='utf-8') as file:
    lines = file.readlines()

# lines = lines[:-toRemove]

lines.extend(karaoke_output)

with open(save_path, 'w', encoding='utf-8') as file:
    file.write('\n'.join(lines))

