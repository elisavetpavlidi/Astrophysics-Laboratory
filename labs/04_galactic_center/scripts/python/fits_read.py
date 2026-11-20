from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
def read_fits(path):
 raw = path.read_bytes()
 cards = [raw[i:i+80].decode() for i in range(0,2880,80)]
 h = {c[:8].strip():c[10:].split('/')[0].strip() for c in cards if c[8:10]=='= '}
 dt={16:'>i2',-32:'>f4'}[int(h['BITPIX'])]
 return np.frombuffer(raw,dtype=dt,count=65536,offset=2880).astype(float).reshape(256,256)*float(h.get('BSCALE',1))+float(h.get('BZERO',0))
