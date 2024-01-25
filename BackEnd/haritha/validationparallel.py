import threading
import numpy as np
import time

# Creating an array of 50 numbers for demonstration
my_array = np.arange(400000)
result_list = []

# Function for the first thread to print the first 25 numbers
def print_first_25(num1,num2):
    s = ""
    for i in range(num1,num2):
        s = s + " " + str(i)
    # s=s+"----------------------------------------------------------------------------------------------" 
    result_list.append(s)   

# Function for the second thread to print the next 25 numbers
start_time = time.time()



# thread1 = threading.Thread(target=print_first_25, args=(0,100000))
# thread2 = threading.Thread(target=print_first_25, args=(100000,200000))
# thread3 = threading.Thread(target=print_first_25, args=(200000,300000))
# thread4 = threading.Thread(target=print_first_25, args=(300000,400000))


# thread1.start()
# thread2.start()
# # thread3.start()
# # thread4.start()

# thread1.join()
# thread2.join()
# thread3.join()
# thread4.join()
end_time = time.time()  # Measure end time
processing_time1 = end_time - start_time

dataSize = 400000
threadCount = 64
coeifficient= int(dataSize/threadCount)
threads = []
start_time = time.time()


for i in range(threadCount):
    thread = threading.Thread(target=print_first_25, args=(i*coeifficient , (i + 1) * coeifficient))
    threads.append(thread)
    thread.start()

for thread in threads:
    thread.join()
    
# for s in result_list:
#     print(s)
    

end_time = time.time()  # Measure end time
processing_time2 = end_time - start_time
print(" multiprocessing 1",processing_time1)

print(" multiprocessing 2",processing_time2)