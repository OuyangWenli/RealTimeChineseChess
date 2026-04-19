#pragma once
#include <QString>
#include <QObject>
#include <QTimer>

class Board;

#define RED 0
#define BLACK 1

class General;

class Piece: public QObject
{
    Q_OBJECT

    Q_PROPERTY(int m_x READ getX NOTIFY xChanged)
    Q_PROPERTY(int m_y READ getY NOTIFY yChanged)
    Q_PROPERTY(bool m_alive READ isAlive NOTIFY aliveChanged)
    Q_PROPERTY(int m_color READ getColor CONSTANT)
    Q_PROPERTY(int m_actionPoint READ getActionPoint WRITE setActionPoint NOTIFY actionPointChanged)
    Q_PROPERTY(int m_maxActionPoint READ getMaxActionPoint WRITE setMaxActionPoint NOTIFY maxActionPointChanged)
    Q_PROPERTY(int m_actionPointRecoveryTime READ getActionPointRecoveryTime WRITE setActionPointRecoveryTime NOTIFY actionPointRecoveryTimeChanged)

signals:
    void xChanged();
    void yChanged();
    void aliveChanged();
    void actionPointChanged();
    void maxActionPointChanged();
    void actionPointRecoveryTimeChanged();

protected:
    int m_x = 0;
    int m_y = 0;
    bool m_alive = true;
    int m_color;
    int m_actionPoint = 2; // 默认每个棋子初始有2点行动力
    int m_maxActionPoint = 2; // 默认每个棋子最大行动力为2
    int m_actionPointRecoveryTime;
    QString m_pieceName;

    QTimer *recoveryTimer;

public:
    Piece(int x, int y, int color);
    virtual ~Piece();

    int getX() const { return m_x; }
    int getY() const { return m_y; }
    int getColor() const { return m_color == RED ? RED : BLACK; }
    bool isAlive() const { return m_alive; }
    int getActionPoint() const { return m_actionPoint; }
    void setActionPoint(int actionPoint) { 
        if (m_actionPoint != actionPoint) {
            m_actionPoint = actionPoint; 
            emit actionPointChanged(); 
            
            if (m_actionPoint < m_maxActionPoint) {
                if (!recoveryTimer->isActive()) {
                    recoveryTimer->start(m_actionPointRecoveryTime);
                }
            } else {
                recoveryTimer->stop();
            }
        }
    }
    int getMaxActionPoint() const { return m_maxActionPoint; }
    int getActionPointRecoveryTime() const { return m_actionPointRecoveryTime; }
    void actionPointRecovery();
    void setMaxActionPoint(int maxAP);
    void setActionPointRecoveryTime(int time);

    virtual bool canMove(int toX, int toY, const Board &board) const = 0;
    virtual std::string getTypeName() const = 0;

    void setPosition(int x, int y) {
        if (this->m_x != x || this->m_y != y) {
            this->m_x = x;
            this->m_y = y;
            emit xChanged();
            emit yChanged();
        }
    }
    
    void revive(int initX, int initY) {
        if (!m_alive) {
            m_alive = true;
            emit aliveChanged();
        }
        setActionPoint(m_maxActionPoint);
        setPosition(initX, initY);
    }

    void isCaptured() {
        if (m_alive) {
            m_alive = false;
            emit aliveChanged();
        }
    }

protected slots:
    void onRecoveryTimerTimeout() {
        actionPointRecovery();
    }
};