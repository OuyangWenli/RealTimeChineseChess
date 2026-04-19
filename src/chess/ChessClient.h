#pragma once

#include <QObject>
#include <QTcpSocket>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonParseError>

class ChessClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int localColor READ getLocalColor NOTIFY localColorChanged)
    Q_PROPERTY(bool isConnected READ getIsConnected NOTIFY isConnectedChanged)

public:
    explicit ChessClient(QObject *parent = nullptr);
    ~ChessClient();

    int getLocalColor() const { return m_localColor; }
    bool getIsConnected() const { return m_isConnected; }

    Q_INVOKABLE void connectToServer(const QString& ip , int port = 8888, int defaultColor = 0);
    Q_INVOKABLE void disconnectFromServer();
    Q_INVOKABLE void sendMove(int fromX, int fromY, int toX, int toY);
    Q_INVOKABLE void sendMatch(const QString& code);

signals:
    void localColorChanged(int color); // 本地玩家颜色改变信号
    void isConnectedChanged(bool connected);
    void moveReceived(int fromX, int fromY, int toX, int toY);
    void matchSuccess();
    void matchFailed(const QString& msg);

private slots:
    void onConnected();
    void onReadyRead();
    void onDisconnected();
    void onError(QAbstractSocket::SocketError socketError);

private:
    void setConnected(bool connected);
    void setLocalColor(int color);

    QTcpSocket* m_socket;
    int m_localColor;
    bool m_isConnected;
};
