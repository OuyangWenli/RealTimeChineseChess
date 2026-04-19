cmake_minimum_required(VERSION 3.16)
project(RealTimeChess VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. 重新引入 Qt 6 模块
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network Multimedia)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

include_directories(src/chess)

file(GLOB_RECURSE SOURCES 
    "src/*.cpp"
    "src/chess/*.cpp"
    "src/chess/*.h"
)

# 2. 定义可执行文件，包含资源文件（稍后创建）
qt_add_executable(RealTimeChess WIN32
    ${SOURCES}
    res/res.qrc
)

# 3. 链接库
target_link_libraries(RealTimeChess PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::Multimedia
)

set_target_properties(RealTimeChess PROPERTIES
    MACOSX_BUNDLE ON
)
