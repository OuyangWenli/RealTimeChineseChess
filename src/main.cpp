#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "Board.h"
#include "Rule.h"
#include "ChessClient.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);// 创建 Qt 应用程序对象

    QQmlApplicationEngine engine;// 创建 QML 应用引擎

    // 创建核心后端对象并注册给 QML 环境
    Board* board = new Board();
    engine.rootContext()->setContextProperty("board", board);

    Rule* rule = new Rule();
    engine.rootContext()->setContextProperty("globalRule", rule);    // 加载 QML 入口点

    ChessClient* network = new ChessClient();
    engine.rootContext()->setContextProperty("network", network);

    const QUrl url(QStringLiteral("qrc:/main.qml"));// 定义 QML 入口点的 URL
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,// 连接信号，当 QML 对象创建完成时检查是否成功加载
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)// 如果对象创建失败且 URL 匹配，退出应用
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);// 加载 QML 文件

    return app.exec();// 启动 Qt 事件循环
}




