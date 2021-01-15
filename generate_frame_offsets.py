import numpy as np

a = [str(s) for s in np.round(np.arange(0, 40*60, 0.4), 2)]

with open('frame_offsets.txt', 'r+') as f:
    f.write('\n'.join(a))
