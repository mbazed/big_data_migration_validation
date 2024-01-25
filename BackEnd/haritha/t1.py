import numpy as np
import time

# Creating an array of 50 numbers for demonstration
my_array = np.arange(400000)

def printnum(num):
    for i in range(num):
        print(my_array[i])

start_time = time.time()
printnum(400000)
end_time = time.time()  # Measure end time
processing_time = end_time - start_time
print(processing_time)