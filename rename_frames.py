import os
path = 'smaller-frames/'
for filename in os.listdir(path):
    seconds, suffix = filename.split('_')
    seconds = seconds.zfill(4)
    new_filename = seconds + "_" + suffix
    os.rename(os.path.join(path, filename), os.path.join(path, new_filename))
