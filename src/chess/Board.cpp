#include "Board.h"
#include "Piece.h"
#include "A.h"
#include "C.h"
#include "S.h"
#include "H.h"
#include "E.h"
#include "R.h"
#include "G.h"

Board::Board(QObject *parent) : QObject(parent), stepCount(0) {
    grid.resize(9, std::vector<Piece*>(10, nullptr)); // 初始化棋盘：横向 9，纵向 10 (grid[x][y] 其中 x=0..8, y=0..9)

    // 红色棋子初始化 (x=横, y=纵)
    // 红方在下 (y=5..9)
    cannons01 = new Cannon(1, 7, RED);
    cannons02 = new Cannon(7, 7, RED);
    soldiers01 = new Soldier(0, 6, RED);
    soldiers02 = new Soldier(2, 6, RED);
    soldiers03 = new Soldier(4, 6, RED);
    soldiers04 = new Soldier(6, 6, RED);
    soldiers05 = new Soldier(8, 6, RED);
    horses01 = new Horse(1, 9, RED);
    horses02 = new Horse(7, 9, RED);
    chariots01 = new Chariot(0, 9, RED);
    chariots02 = new Chariot(8, 9, RED);
    advisors01 = new Advisor(3, 9, RED);
    advisors02 = new Advisor(5, 9, RED);
    elephants01 = new Elephant(2, 9, RED);
    elephants02 = new Elephant(6, 9, RED);
    general01 = new General(4, 9, RED);

    // 黑色棋子初始化 (x=横, y=纵)
    // 黑方在上 (y=0..4)
    cannons11 = new Cannon(1, 2, BLACK);
    cannons12 = new Cannon(7, 2, BLACK);
    soldiers11 = new Soldier(0, 3, BLACK);
    soldiers12 = new Soldier(2, 3, BLACK);
    soldiers13 = new Soldier(4, 3, BLACK);
    soldiers14 = new Soldier(6, 3, BLACK);
    soldiers15 = new Soldier(8, 3, BLACK);
    horses11 = new Horse(1, 0, BLACK);
    horses12 = new Horse(7, 0, BLACK);
    chariots11 = new Chariot(0, 0, BLACK);
    chariots12 = new Chariot(8, 0, BLACK);
    advisors11 = new Advisor(3, 0, BLACK);
    advisors12 = new Advisor(5, 0, BLACK);
    elephants11 = new Elephant(2, 0, BLACK);
    elephants12 = new Elephant(6, 0, BLACK);
    general11 = new General(4, 0, BLACK);

    // 进攻棋子放在前面 (0-10: 炮, 兵, 马, 车)
    pieceRed[0] = cannons01; pieceRed[1] = cannons02;
    pieceRed[2] = soldiers01; pieceRed[3] = soldiers02; pieceRed[4] = soldiers03; pieceRed[5] = soldiers04; pieceRed[6] = soldiers05;
    pieceRed[7] = horses01; pieceRed[8] = horses02;
    pieceRed[9] = chariots01; pieceRed[10] = chariots02;
    // 防守棋子和将放在后面 (11-15: 士, 象, 将)
    pieceRed[11] = advisors01; pieceRed[12] = advisors02;
    pieceRed[13] = elephants01; pieceRed[14] = elephants02;
    pieceRed[15] = general01;

    pieceBlack[0] = cannons11; pieceBlack[1] = cannons12;
    pieceBlack[2] = soldiers11; pieceBlack[3] = soldiers12; pieceBlack[4] = soldiers13; pieceBlack[5] = soldiers14; pieceBlack[6] = soldiers15;
    pieceBlack[7] = horses11; pieceBlack[8] = horses12;
    pieceBlack[9] = chariots11; pieceBlack[10] = chariots12;
    pieceBlack[11] = advisors11; pieceBlack[12] = advisors12;
    pieceBlack[13] = elephants11; pieceBlack[14] = elephants12;
    pieceBlack[15] = general11;

    // 在棋盘上放置初始棋子
    for (int i = 0; i < 16; i++) {
        if (pieceRed[i]) setPiece(pieceRed[i]->getX(), pieceRed[i]->getY(), pieceRed[i]);
        if (pieceBlack[i]) setPiece(pieceBlack[i]->getX(), pieceBlack[i]->getY(), pieceBlack[i]);
    }
}

Board::~Board()
{
    for (int i = 0; i < 16; i++)
    {
        delete pieceRed[i];
        delete pieceBlack[i];
    }
}

void Board::setPiece(int x, int y, Piece* p) {
    if (p) {
        p->setParent(this);
    }
    grid[x][y] = p;
}

// 移动棋子
void Board::movePiece(int fromX, int fromY, int toX, int toY) {
    Piece* piece = getPiece(fromX, fromY);
    if(piece != nullptr && piece->canMove(toX, toY, *this)) {
        bool generalCaptured = false;
        int targetColor = 1 - piece->getColor(); // 被攻击方的颜色

        if(grid[toX][toY] != nullptr) {
            if (dynamic_cast<General*>(grid[toX][toY])) { //使用 dynamic_cast 检查目标位置是否为将
                generalCaptured = true; // 将被吃掉了
            }
            grid[toX][toY]->isCaptured();
            stepCount = 0;
        }
        grid[toX][toY] = piece;
        grid[piece->getX()][piece->getY()] = nullptr;
        piece->setPosition(toX, toY);
        stepCount++;
        
        if (generalCaptured) {
            emit gameOver(piece->getColor());
        }
    }
}
Piece* Board::getPiece(int x, int y) const {
    if (x < 0 || x > 8 || y < 0 || y > 9) return nullptr;
    return grid[x][y];
}

QObject* Board::getPieceQml(int x, int y) const {
    if (x < 0 || x > 8 || y < 0 || y > 9) return nullptr;
    return grid[x][y];
}

std::vector<Piece*> Board::getPieceArr(int color) const {
    if(color==RED){
        return std::vector<Piece*>(pieceRed, pieceRed + 16);
    }
    return std::vector<Piece*>(pieceBlack, pieceBlack + 16);
}

// 获取指定颜色的将
General* Board::getGeneral(int color) const {
    return (color == 0) ? general01 : general11;
}

// 验证移动合法性
bool Board::canMove(int fromX, int fromY, int toX, int toY) {
    Piece* p = getPiece(fromX, fromY);
    if (!p || !p->isAlive()) {
        return false;
    }

    // 不能移动到自己的棋子上
    Piece* target = getPiece(toX, toY);
    if (target && target->isAlive() && target->getColor() == p->getColor()) {
        return false;
    }

    bool res = p->canMove(toX, toY, *this);
    return res;
}

// 判断游戏是否结束：如果任一将被吃掉，游戏结束
bool Board::isGameOver() const {
    return !general01->isAlive() || !general11->isAlive();
}

int Board::getWinner() const {
    if (!general01->isAlive()) return 1; // 黑胜
    if (!general11->isAlive()) return 0; // 红胜
    return -1;
}

// 和棋判断：双方没有进攻棋子或60步没有吃子
bool Board::isNoAttackPiece(int color) const {
    auto pieces = getPieceArr(color);
    auto oppPieces = getPieceArr(1 - color);
    for(size_t i = 0; i < 11 && i < 16; i++){
        if (pieces[i]->isAlive() || oppPieces[i]->isAlive()) {
            return false;
        }
    }
    return true;
}

// 60步无吃子判断
bool Board::isFiftyMovesWithoutCapture() const {
    return (stepCount >= 60);
}

void Board::resetBoard() {
    stepCount = 0;

    // 清空棋盘二维数组
    for (int x = 0; x < 9; ++x) {
        for (int y = 0; y < 10; ++y) {
            grid[x][y] = nullptr;
        }
    }

    // 复活红色棋子到初始位置
    cannons01->revive(1, 7);
    cannons02->revive(7, 7);
    soldiers01->revive(0, 6);
    soldiers02->revive(2, 6);
    soldiers03->revive(4, 6);
    soldiers04->revive(6, 6);
    soldiers05->revive(8, 6);
    horses01->revive(1, 9);
    horses02->revive(7, 9);
    chariots01->revive(0, 9);
    chariots02->revive(8, 9);
    advisors01->revive(3, 9);
    advisors02->revive(5, 9);
    elephants01->revive(2, 9);
    elephants02->revive(6, 9);
    general01->revive(4, 9);

    // 复活黑色棋子到初始位置
    cannons11->revive(1, 2);
    cannons12->revive(7, 2);
    soldiers11->revive(0, 3);
    soldiers12->revive(2, 3);
    soldiers13->revive(4, 3);
    soldiers14->revive(6, 3);
    soldiers15->revive(8, 3);
    horses11->revive(1, 0);
    horses12->revive(7, 0);
    chariots11->revive(0, 0);
    chariots12->revive(8, 0);
    advisors11->revive(3, 0);
    advisors12->revive(5, 0);
    elephants11->revive(2, 0);
    elephants12->revive(6, 0);
    general11->revive(4, 0);

    for (int i = 0; i < 16; i++) {
        if (pieceRed[i]) setPiece(pieceRed[i]->getX(), pieceRed[i]->getY(), pieceRed[i]);
        if (pieceBlack[i]) setPiece(pieceBlack[i]->getX(), pieceBlack[i]->getY(), pieceBlack[i]);
    }

    // 重置后通知前端解绑旧指针重新读取新指针
    emit boardReset();
}
