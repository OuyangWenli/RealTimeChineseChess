#include "Rule.h"

Rule::Rule(QObject *parent) : QObject(parent),
    point_red(1), point_black(1),
    MaxPoint_red(4), MaxPoint_black(4),
    pointRecoveryTime_red(7000), pointRecoveryTime_black(3500)
{
    redTimer = new QTimer(this);
    redTimer->setInterval(pointRecoveryTime_red);
    connect(redTimer, &QTimer::timeout, this, &Rule::recoverRedPoint);

    blackTimer = new QTimer(this);
    blackTimer->setInterval(pointRecoveryTime_black);
    connect(blackTimer, &QTimer::timeout, this, &Rule::recoverBlackPoint);
}

void Rule::startRecovery() {
    if (!redTimer->isActive()) redTimer->start();
    if (!blackTimer->isActive()) blackTimer->start();
}

void Rule::stopRecovery() {
    if (redTimer->isActive()) redTimer->stop();
    if (blackTimer->isActive()) blackTimer->stop();
}

void Rule::resetRule() {
    stopRecovery();
    setPointRed(0);
    setPointBlack(0);
}

void Rule::recoverRedPoint() {
    if (point_red < MaxPoint_red) {
        setPointRed(point_red + 1);
    }
}

void Rule::recoverBlackPoint() {
    if (point_black < MaxPoint_black) {
        setPointBlack(point_black + 1);
    }
}

void Rule::setPointRecoveryTimeRed(int time) {
    if (pointRecoveryTime_red != time) {
        pointRecoveryTime_red = time;
        if (redTimer->isActive()) {
            redTimer->setInterval(pointRecoveryTime_red);
        } else {
            redTimer->setInterval(pointRecoveryTime_red);
        }
        emit pointRecoveryTimeRedChanged();
    }
}

void Rule::setPointRecoveryTimeBlack(int time) {
    if (pointRecoveryTime_black != time) {
        pointRecoveryTime_black = time;
        if (blackTimer->isActive()) {
            blackTimer->setInterval(pointRecoveryTime_black);
        } else {
            blackTimer->setInterval(pointRecoveryTime_black);
        }
        emit pointRecoveryTimeBlackChanged();
    }
}
