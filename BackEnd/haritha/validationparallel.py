import threading
import numpy as np
import time

# Creating an array of 50 numbers for demonstration
my_array = np.arange(400000)

# Function for the first thread to print the first 25 numbers
def print_first_25(num1,num2):
    for i in range(num1,num2):
        print(my_array[i])

# Function for the second thread to print the next 25 numbers


# Creating two threads
thread1 = threading.Thread(target=print_first_25, args=(0,100000))
thread2 = threading.Thread(target=print_first_25, args=(100000,200000))
thread3 = threading.Thread(target=print_first_25, args=(200000,300000))
thread4 = threading.Thread(target=print_first_25, args=(300000,400000))

# Starting both threads
thread1.start()
thread2.start()
start_time = time.time()

# Waiting for both threads to finish
thread1.join()
thread2.join()

end_time = time.time()  # Measure end time
processing_time = end_time - start_time
print(processing_time)