#pragma once
#include <iostream>
#include <QObject>
#include <QTimer>

class Rule: public QObject
{
    Q_OBJECT
    Q_PROPERTY(int point_red READ getPointRed WRITE setPointRed NOTIFY pointRedChanged)
    Q_PROPERTY(int point_black READ getPointBlack WRITE setPointBlack NOTIFY pointBlackChanged)
    Q_PROPERTY(int MaxPoint_red READ getMaxPointRed NOTIFY maxPointRedChanged)
    Q_PROPERTY(int MaxPoint_black READ getMaxPointBlack NOTIFY maxPointBlackChanged)
    Q_PROPERTY(int pointRecoveryTime_red READ getPointRecoveryTimeRed WRITE setPointRecoveryTimeRed NOTIFY pointRecoveryTimeRedChanged)
    Q_PROPERTY(int pointRecoveryTime_black READ getPointRecoveryTimeBlack WRITE setPointRecoveryTimeBlack NOTIFY pointRecoveryTimeBlackChanged)

public:
    explicit Rule(QObject *parent = nullptr);

    int getPointRed() const { return point_red; }
    void setPointRed(int p) {
        if (point_red != p) {
            point_red = p;
            emit pointRedChanged();
        }
    }

    int getPointBlack() const { return point_black; }
    void setPointBlack(int p) {
        if (point_black != p) {
            point_black = p;
            emit pointBlackChanged();
        }
    }

    int getMaxPointRed() const { return MaxPoint_red; }
    int getMaxPointBlack() const { return MaxPoint_black; }
    int getPointRecoveryTimeRed() const { return pointRecoveryTime_red; }
    int getPointRecoveryTimeBlack() const { return pointRecoveryTime_black; }
    
    Q_INVOKABLE void setPointRecoveryTimeRed(int time);
    Q_INVOKABLE void setPointRecoveryTimeBlack(int time);

    Q_INVOKABLE void startRecovery();
    Q_INVOKABLE void stopRecovery();
    Q_INVOKABLE void resetRule(); // 重置规则，主要是重置积分和停止计时器

signals:
    void pointRedChanged();
    void pointBlackChanged();
    void maxPointRedChanged();
    void maxPointBlackChanged();
    void pointRecoveryTimeRedChanged();
    void pointRecoveryTimeBlackChanged();

private:
    int point_red;
    int point_black;
    int MaxPoint_red;
    int MaxPoint_black;
    int pointRecoveryTime_red;
    int pointRecoveryTime_black;

    QTimer* redTimer;
    QTimer* blackTimer;

private slots:
    void recoverRedPoint();
    void recoverBlackPoint();
};