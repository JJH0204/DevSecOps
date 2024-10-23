from hashlib import *
from multiprocessing import *
def create(num):
    start = 10000000*num
    end = 10000000*(num+1)
    f = open('table.csv', mode = 'w', encoding = 'utf-8')
    for i in range(start, end):
        txt = str(i) + "salt_for_you"
        result = txt
        for j in range(0, 500):
            result = sha1(result.encode('utf-8')).hexdigest()
        print(result)
        f.write(f'{txt} ======> result : {result}\n')
    f.close()

if __name__ == '__main__':
    procs = []
    for i in range(1, 10):
        proc = Process(target = create, args = (i,))
        procs.append(proc)
        proc.start()

    for proc in procs:
        proc.join()