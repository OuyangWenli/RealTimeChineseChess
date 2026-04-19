#include "ChessClient.h"
#include <QDebug>

ChessClient::ChessClient(QObject *parent) : QObject(parent), m_localColor(0), m_isConnected(false) {
    m_socket = new QTcpSocket(this);
    connect(m_socket, &QTcpSocket::connected, this, &ChessClient::onConnected);
    connect(m_socket, &QTcpSocket::readyRead, this, &ChessClient::onReadyRead);
    connect(m_socket, &QTcpSocket::disconnected, this, &ChessClient::onDisconnected);
    connect(m_socket, &QTcpSocket::errorOccurred, this, &ChessClient::onError);
}

ChessClient::~ChessClient() {
    disconnectFromServer();
}

void ChessClient::connectToServer(const QString& ip, int port, int color) {
    disconnectFromServer();
    setLocalColor(color);
    qDebug() << "正在连接到" << ip << ":" << port;
    m_socket->connectToHost(ip, port);
}

void ChessClient::sendMatch(const QString& code) {
    if (!m_socket || !m_isConnected) return;

    QJsonObject json;
    json["type"] = "match";
    json["code"] = code;

    QJsonDocument doc(json);
    m_socket->write(doc.toJson(QJsonDocument::Compact) + '\n');
    m_socket->flush();
}

void ChessClient::disconnectFromServer() {
    setConnected(false);
    m_socket->abort(); // 仅中断连接而不销毁对象
}

void ChessClient::sendMove(int fromX, int fromY, int toX, int toY) {
    if (!m_socket || !m_isConnected) return;

    QJsonObject json;
    json["type"] = "move";
    json["fromX"] = fromX;
    json["fromY"] = fromY;
    json["toX"] = toX;
    json["toY"] = toY;

    QJsonDocument doc(json);
    m_socket->write(doc.toJson(QJsonDocument::Compact) + '\n');
    m_socket->flush();
}

void ChessClient::onConnected() {
    qDebug() << "成功连接到服务器！";
    setConnected(true);
}

void ChessClient::onReadyRead() {
    while (m_socket && m_socket->isValid() && m_socket->canReadLine()) {
        QByteArray data = m_socket->readLine();
        QJsonParseError error;
        QJsonDocument doc = QJsonDocument::fromJson(data, &error);

        if (error.error == QJsonParseError::NoError && doc.isObject()) {
            QJsonObject json = doc.object();
            if (json["type"] == "move") {
                int fx = json["fromX"].toInt();
                int fy = json["fromY"].toInt();
                int tx = json["toX"].toInt();
                int ty = json["toY"].toInt();
                emit moveReceived(fx, fy, tx, ty);
            } else if (json["type"] == "matched") {
                int assignedColor = json["color"].toInt();
                setLocalColor(assignedColor);
                emit matchSuccess();
            } else if (json["type"] == "error") {
                emit matchFailed(json["msg"].toString());
            }
        }
    }
}

void ChessClient::onDisconnected() {
    qDebug() << "从服务器断开连接！";
    setConnected(false);
}

void ChessClient::onError(QAbstractSocket::SocketError socketError) {
    qDebug() << "Socket Error (int):" << static_cast<int>(socketError);
}

void ChessClient::setConnected(bool connected) {
    if (m_isConnected != connected) {
        m_isConnected = connected;
        emit isConnectedChanged(m_isConnected);
    }
}

void ChessClient::setLocalColor(int color) {
    if (m_localColor != color) {
        m_localColor = color;
        emit localColorChanged(m_localColor);
    }
}
