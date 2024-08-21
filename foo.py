import numpy as np
import json
class foo(dict):
    def __init__(self,*args,**kargs)->None:
        super().__init__(**kargs)
    def foo(self):
        for i in range(10):
            self[f"{1.1*1.1:1.2}a"]=0
        print('hello word')