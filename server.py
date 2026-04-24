import socket
import threading
import json
import traceback

# 存放所有的房间记录，结构: { "房间码": {"player1": writer, "player2": writer} }
rooms = {}      
# 存放每个客户端所在的房间，结构: { writer: "房间码" }
client_rooms = {} 

def handle_client(conn, addr):
    print(f"玩家连接成功: {addr}")
    try:
        while True:
            # 读取数据
            data = b''
            while b'\n' not in data:
                chunk = conn.recv(1024)
                if not chunk:
                    break
                data += chunk
            if not data:
                break
                
            msg = data.decode('utf-8').strip()
            if not msg: continue
            
            try:
                req = json.loads(msg)
            except:
                continue

            req_type = req.get('type')

            if req_type == 'match':
                code = req.get('code')
                if not code: continue
                
                room = rooms.get(code)
                if room:
                    if room['p1'] and not room['p2']:
                        room['p2'] = conn
                        client_rooms[conn] = code

                        room['p1'].sendall((json.dumps({"type": "matched", "color": 0}) + "\n").encode('utf-8'))
                        conn.sendall((json.dumps({"type": "matched", "color": 1}) + "\n").encode('utf-8'))
                        print(f"[{code}] 房间匹配成功！")
                    else:
                        conn.sendall((json.dumps({"type": "error", "msg": "对战码已被其他玩家占用，换一个试试呢？"}) + "\n").encode('utf-8'))
                else:
                    rooms[code] = {'p1': conn, 'p2': None}
                    client_rooms[conn] = code
                    print(f"[{code}] 创建已房间，等待中...")
                    
            elif req_type == 'move':
                code = client_rooms.get(conn)
                if code and code in rooms:
                    room = rooms[code]
                    # 同时发给双端，实现绝对的服务器权威同步
                    if room['p1']:
                        try: room['p1'].sendall(data)
                        except: pass
                    if room['p2']:
                        try: room['p2'].sendall(data)
                        except: pass
                        
    except Exception as e:
        print(f"异常: {e}")
    finally:
        code = client_rooms.pop(conn, None)
        if code and code in rooms:
            room = rooms[code]
            if room['p1'] == conn: room['p1'] = None
            elif room['p2'] == conn: room['p2'] = None
            
            if not room['p1'] and not room['p2']:
                del rooms[code]
                print(f"[{code}] 房间已销毁。")
            else:
                remaining = room['p1'] or room['p2']
                if remaining:
                    try: remaining.sendall((json.dumps({"type": "error", "msg": "Opponent disconnected"}) + "\n").encode('utf-8'))
                    except: pass
        try: conn.close()
        except: pass
        print(f"脱离: {addr}")

if __name__ == '__main__':
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    server.bind(('0.0.0.0', 8888))
    server.listen(100)
    print("硬核多线程服务器已启动，正在监听端口 8888 ...")
    
    while True:
        try:
            conn, addr = server.accept()
            threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()
        except KeyboardInterrupt:
            print("服务器关闭。")
            break
