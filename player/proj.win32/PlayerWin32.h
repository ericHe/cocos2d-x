
#ifndef __PLAYER_WIN32_H_
#define __PLAYER_WIN32_H_

#include "PlayerProtocol.h"

PLAYER_NS_BEGIN

class PlayerWin32 :
    public PlayerProtocol
{
public:
    virtual ~PlayerWin32();

    virtual FileDialogServiceProtocol *getFileDialogService();

protected:
    PlayerWin32();


};

PLAYER_NS_END

#endif // __PLAYER_WIN32_H_
