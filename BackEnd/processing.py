import multiprocessing
import time
import numpy as np

def multiply_part(arr_part, result, start_index):
    for i, num in enumerate(arr_part):
        result[start_index + i] = num * 2
        time.sleep(0.0000001)
        
def parallel(arr,shared_array_np,num_processes):
    start_time = time.time()
    for i in range(num_processes):
        start_index = i * chunk_size
        end_index = (i + 1) * chunk_size if i < num_processes - 1 else len(arr)
        arr_part = arr[start_index:end_index]

        process = multiprocessing.Process(target=multiply_part, args=(arr_part, shared_array_np, start_index))
        processes.append(process)
        process.start()

    for process in processes:
        process.join()

    end_time = time.time()  # Measure end time
    multiprocessing_time = end_time - start_time

    print(f"[{num_processes}]Multiprocessing processing time:", multiprocessing_time)


if __name__ == "__main__":
    arr = np.arange(1, 1001)  # Creating an array of numbers from 1 to 1000000
    print("size: ",len(arr))
    num_processes = 15
    chunk_size = len(arr) // num_processes

    processes = []
    shared_array = multiprocessing.Array('i', len(arr), lock=False)  # 'i' for signed int
    shared_array_np = np.frombuffer(shared_array, dtype=np.int32)  # Convert shared array to numpy array for convenience

    
    shared_array2 = multiprocessing.Array('i', len(arr), lock=False)  # 'i' for signed int
    shared_array_np2 = np.frombuffer(shared_array2, dtype=np.int32)
    # Perform sequential operation
    start_time = time.time()
    # multiply_part(arr,shared_array_np2,0)
    end_time = time.time()  # Measure end time
    sequential_processing_time = end_time - start_time

    print("Sequential processing time:", sequential_processing_time)

    # Perform multiprocessing
    
    for i in range(15,25,1):
        parallel(arr,shared_array_np,i)
    
