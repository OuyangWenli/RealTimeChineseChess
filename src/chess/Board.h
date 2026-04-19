#pragma once

#include <vector>
#include <string>
#include <QObject>

class Piece;
class Advisor;
class Cannon;
class Soldier;
class Horse;
class Elephant;
class Chariot;
class General;

using namespace std;

class Board : public QObject
{
    Q_OBJECT
private:
    vector<vector<Piece*>> grid; 
    int stepCount = 0; // 记步器

    // 棋子对象
    Advisor* advisors01,* advisors02,* advisors11,* advisors12;
    Cannon* cannons01,* cannons02,* cannons11,* cannons12;
    Soldier* soldiers01,* soldiers02,* soldiers03,* soldiers04,* soldiers05,* soldiers11,* soldiers12,* soldiers13,* soldiers14,* soldiers15;
    Horse* horses01,* horses02,* horses11,* horses12;
    Elephant* elephants01,* elephants02,* elephants11,* elephants12;
    Chariot* chariots01,* chariots02,* chariots11,* chariots12;
    General* general01,* general11;
    // 棋子数组
    Piece* pieceRed[16];
    Piece* pieceBlack[16];

public:
    explicit Board(QObject *parent = nullptr);
    ~Board();
    void setPiece(int x, int y, Piece *p); // 在指定位置放置棋子

    Q_INVOKABLE bool canMove(int fromX, int fromY, int toX, int toY); // 验证移动合法性
    Q_INVOKABLE void movePiece(int fromX, int fromY, int toX, int toY); // 移动棋子

    Q_INVOKABLE Piece* getPiece(int x, int y) const; // 获取指定位置的棋子
    Q_INVOKABLE QObject* getPieceQml(int x, int y) const; // 给QML用的获取棋子

    std::vector<Piece *> getPieceArr(int color) const; // 获得指定颜色的棋子数组
    General *getGeneral(int color) const; // 获取指定颜色的将

    bool isNoAttackPiece(int color) const; // 检查指定颜色方是否已无进攻性棋子
    bool isFiftyMovesWithoutCapture() const; // 判断是否达到60步无吃子（和棋规则）
    bool isTieGame() const;
    bool isGameOver() const;
    int getWinner() const;

    Q_INVOKABLE void resetBoard();

signals:
    void gameOver(int winner);
    void boardReset();
};
