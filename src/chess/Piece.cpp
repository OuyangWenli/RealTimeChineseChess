#include "Piece.h"

Piece::Piece(int x, int y, int color) : m_x(x), m_y(y), m_color(color), m_alive(true) {
    m_actionPointRecoveryTime = 3000; // 默认给3000，具体在子类修改
    recoveryTimer = new QTimer(this);
    connect(recoveryTimer, &QTimer::timeout, this, &Piece::onRecoveryTimerTimeout);
    // 这里不再立刻 start，而是在行动点减少时（或有不满足 maxAP 时）才开始跑，以防止后台偷跑
}

Piece::~Piece() {
    // 移除强行 delete recoveryTimer; 的操作
    // 因为 recoveryTimer 在实例化时绑定了 this 作为父对象
    // Qt 的对象树机制会在当前对象销毁时，自动安全销毁其所有子对象，手动 delete 极容易导致双重释放段错误
}

void Piece::actionPointRecovery() {
    if (m_actionPoint < m_maxActionPoint) {
        m_actionPoint++;
        emit actionPointChanged();
        if (m_actionPoint >= m_maxActionPoint) {
            recoveryTimer->stop();
        }
    }
}

void Piece::setMaxActionPoint(int maxAP) {
    if (m_maxActionPoint != maxAP) {
        m_maxActionPoint = maxAP;
        emit maxActionPointChanged();
    }
}

void Piece::setActionPointRecoveryTime(int time) {
    if (m_actionPointRecoveryTime != time) {
        m_actionPointRecoveryTime = time;
        
        // 动态修改计时器触发间隔
        if (recoveryTimer->isActive()) {
            recoveryTimer->setInterval(m_actionPointRecoveryTime);
        }
        
        emit actionPointRecoveryTimeChanged();
    }
}

