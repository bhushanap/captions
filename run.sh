# Check if virtual environment is active
if [ -n "$VIRTUAL_ENV" ]; then
    deactivate
fi

# Get the directory of the script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -d "caption" ]; then
    source caption/bin/activate
else
    python3 -m venv caption && source caption/bin/activate
fi

# Remove all .ass, .srt, and out.mp4 files
rm -f *.ass *.srt *output.mp4



# Find the first MP4 file in the current directory and its subdirectories
video_file=$(find . -type f -name "*.mp4" | head -n 1)

# Throw an error and exit if no MP4 file is found
if [ -z "$video_file" ]; then
    echo "Error: No MP4 file found. Exiting."
    exit 1
fi

# Extract the filename without extension for the video file
video_filename=$(basename "$video_file" .mp4)

# Find the first MP3 file in the current directory and its subdirectories
audio_file=$(find . -type f -name "*.mp3" | head -n 1)

# If found, extract the basename
if [ -n "$audio_file" ]; then
    audio_filename=$(basename "$audio_file" .mp3)
else
    # If no MP3 file is found, create one from an MP4 file with video_filename.mp3
    ffmpeg -i "$video_file" -q:a 0 -map a "$video_filename.mp3"
    audio_file="$video_filename.mp3"
    audio_filename="$video_filename"
fi

# Run caption.py with the selected audio file to generate SRT file
python3 caption.py "$audio_file" && \

# Create ASS from SRT and apply the styles
ffmpeg -i "$audio_filename.srt" "$audio_filename.ass" -y && \

# Combine video and audio with subtitles
ffmpeg -i "$video_file" -i "$audio_file" -vf "ass=$audio_filename.ass" -vsync 2 "$video_filename.output.mp4" -y




