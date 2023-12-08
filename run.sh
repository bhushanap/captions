#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if the "caption" directory exists
if [ -d "caption" ]; then
    # Check if virtual environment is not active
    if [ -z "$VIRTUAL_ENV" ]; then
        source caption/bin/activate
    fi
else
    python3 -m venv caption && source caption/bin/activate
fi

# Remove all .ass, .srt, and out.mp4 files
rm -f *.ass *.srt *output.mp4

# Load variables from cfg.yml file
cfg_file="cfg.yml"

# Function to get value from YAML file
get_yaml_value() {
    local key=$1
    local value=$(yq eval ".$key" "$cfg_file")
    echo "$value"
}

# Video options
video_filename=$(get_yaml_value "video_filename")
extract_audio=$(get_yaml_value "extract_audio")
audio_filename=$(get_yaml_value "audio_filename")
resolutionx=$(get_yaml_value "resolutionx")
resolutiony=$(get_yaml_value "resolutiony")

# SRT generation options
srt_save_file=$(get_yaml_value "srt_generate.save_file")
srt_model=$(get_yaml_value "srt_generate.model")
srt_n_threads=$(get_yaml_value "srt_generate.n_threads")

# ASS generation options
ass_config_file=$(get_yaml_value "ass_generate.config_file")
ass_rows=$(get_yaml_value "ass_generate.rows")
ass_row_height=$(get_yaml_value "ass_generate.row_height")
ass_max_words_per_line=$(get_yaml_value "ass_generate.max_words_per_line")
ass_max_chars_per_line=$(get_yaml_value "ass_generate.max_chars_per_line")
ass_max_duration_per_line=$(get_yaml_value "ass_generate.max_duration_per_line")
ass_effect=$(get_yaml_value "ass_generate.effect")
ass_font_size=$(get_yaml_value "ass_generate.font_size")
ass_font_style=$(get_yaml_value "ass_generate.font_style")
ass_font_color=$(get_yaml_value "ass_generate.font_color")
ass_border_color=$(get_yaml_value "ass_generate.border_color")

# Find MP4 file with the video file name in the current directory and its subdirectories
video_file=$(find . -type f -name "$video_filename" | head -n 1)

# If not found, use any file ending in mp4 and throw a warning desired mp4 file not found, running with xyz file
if [ -z "$video_file" ]; then
    echo "Warning: Desired MP4 file not found. Running with any found mp4 file."
    video_file=$(find . -type f -name "*.mp4" | head -n 1)
fi

# Throw an error and exit if no MP4 file is found. Wait a few seconds before exiting so that the error can be seen
if [ -z "$video_file" ]; then
    echo "Error: No MP4 file found. Exiting."
    sleep 5
    exit 1
fi

# Extract the filename without extension for the video file
video_filename=$(basename "$video_file" .mp4)

# If extract audio is true, then extract audio from the video file and store it with the given audio file name
if [ "$extract_audio" == "true" ]; then
    ffmpeg -i "$video_file" -q:a 0 -map a "$audio_filename" -y
    audio_file="$audio_filename"
else
    # Find the audio file with the specified file name
    audio_file=$(find . -type f -name "$audio_filename" | head -n 1)

    # If not found, find the first MP3 file in the current directory and its subdirectories and throw that warning
    if [ -z "$audio_file" ]; then
        echo "Warning: Desired audio file not found. Running with any found mp3 file."
        audio_file=$(find . -type f -name "*.mp3" | head -n 1)
    fi
fi

# If found, extract the basename
if [ -n "$audio_file" ]; then
    audio_filename=$(basename "$audio_file" .mp3)
else
    # If no MP3 file is found, create one from an MP4 file with video_filename.mp3
    ffmpeg -i "$video_file" -q:a 0 -map a "$audio_filename"
    audio_file="$audio_filename"
fi

# If even the extraction fails, throw an error, extraction failed and exit. Wait a few seconds before exiting so that the error can be seen
if [ ! -f "$audio_file" ]; then
    echo "Error: Audio extraction failed. Exiting."
    sleep 5
    exit 1
fi

# Run caption.py with the above audio file to generate captions
echo $srt_n_threads
python3 caption.py "$audio_file" "$srt_save_file" "$srt_model" $srt_n_threads && \

# Create ASS from SRT with the same basename
ffmpeg -i "$srt_save_file" "$audio_filename.ass" -y && \

# Set the config file for ASS
# python3 configAss.py # (Dont touch this)

# Convert the ASS files to the desired karaoke format
# rows: row_height: max_words_per_line: max_chars_per_line: max_duration_per_line:
python3 ass2kar.py "$audio_filename.ass" "$ass_config_file" "$ass_rows" "$ass_row_height" "$ass_max_words_per_line" "$ass_max_chars_per_line" "$ass_max_duration_per_line" && \

# Choose which effect script (pop.py, particles.py, slide.py) to use as per yaml and run it with the following format naming
python3 "$ass_effect.py" "$video_filename.output.ass" && \

# Combine video and audio with subtitles, video resolution as per yml cfg
ffmpeg -i "$video_file" -i "$audio_file" -vf "ass=$video_filename.output.ass" -s "${resolutionx}x${resolutiony}" -vsync 2 "$video_filename.output.mp4" -y
