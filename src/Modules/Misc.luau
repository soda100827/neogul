return function(Globals)
local Library = Globals.Library
local Toggles = Library.Toggles
local Options = Library.Options

local MessageTemplates = {
    English = {
        Roast = {
            'Are you playing with your monitor off?',
            'Is that a bot or a player?',
            'I think the tutorial boss was harder than you.',
            'Your aim is allergic to players.',
            'You missed... again.',
            'Are you using a trackpad?',
            'Refund your internet, it\'s wasted on you.',
            'My cat could aim better.',
            'Nice strategy, dying repeatedly.',
            'Just leave, save your KD.',
            'I\'d say uninstall, but you probably missed the button.'
        },
        Toxic = {
            'EZ',
            'Skill issue',
            'Gap',
            'Trash',
            'Tutorial complete?',
            'You\'re awful',
            'Bot movement',
            'Cry about it',
            'Mad because bad',
            'Imagine being this bad',
            'Get rolled'
        },
        HvH = {
            'Nice free paste.',
            'Did you get that script from a cereal box?',
            'My config costs more than your PC.',
            'Update your cheat, it\'s outdated.',
            'Refund your subscription.',
            'Are you even trying?',
            'Config issue or brain issue?',
            'Nice silent aim, does it hit anything?',
        }
    },
    Korean = {
        Roast = {
            '모니터 끄고 게임하시나요?',
            '봇인줄 알았네 ㅋㅋ',
            '튜토리얼 보스가 더 잘할듯',
            '에임이 사람을 피해가네요',
            '와 그걸 못 맞추네',
            '트랙패드로 게임함?',
            '인터넷 요금이 아깝다',
            '우리집 고양이가 더 잘 쏠듯',
            '계속 죽는 게 전략인가요?',
            '그냥 나가시는 게 킬뎃 보호에 좋을듯',
            '게임 삭제하라고 하고 싶은데 삭제 버튼도 못 누를듯'
        },
        Toxic = {
            '허접',
            '실력 차이',
            '수준 ㄷㄷ',
            '쓰레기',
            '튜토리얼은 깸?',
            '개못하네',
            '너무 못해',
            '봇 무빙',
            '울지마',
            '화났쥬?',
            '이렇게 못하기도 힘들겠다',
            '털렸죠?'
        },
        HvH = {
            '어디서 주워온 무료 핵 씀?',
            '니 핵은 그게 한계냐?',
            '내 설정이 니 컴퓨터보다 비쌀듯',
            '핵 업데이트 좀 해라 구닥다리네',
            '그거 돈 주고 산 거임? 환불해라',
            '진심으로 하는 거임?',
            '설정 문제냐 지능 문제냐?',
            '사일런트 에임 킨 거 맞음? 하나도 안 맞네',
            '짭 스크립트 수준 ㅋㅋ'
        }
    }
}

-- Chat Spammer Logic
task.spawn(function()
    while true do
        if Options.ChatSpammerDelay then
             task.wait(Options.ChatSpammerDelay.Value)
        else
             task.wait(3)
        end
        
        if Toggles.ChatSpammer and Toggles.ChatSpammer.Value then
            local lang = Options.ChatSpammerLanguage.Value
            local msgType = Options.ChatSpammerType.Value
            local msgList = {}
            
            if msgType == 'Custom' then
                msgList = Globals.CustomSpammerMessages or {}
            elseif MessageTemplates[lang] and MessageTemplates[lang][msgType] then
                msgList = MessageTemplates[lang][msgType]
            else
                 msgList = {'Default message'}
            end

            if #msgList > 0 then
                local TextChat = msgList[math.random(1, #msgList)]
                pcall(function()
                     game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(TextChat)
                end)
            end
        end
    end
end)

-- Kill Say Logic
task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function GetEliminationFeedModule()
        local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
        if scripts then
            for _, v in pairs(scripts:GetDescendants()) do
                if v:IsA("ModuleScript") and v.Name == "EliminationFeed" then
                    return v
                end
            end
        end
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("ModuleScript") and v.Name == "EliminationFeed" then
                return v
            end
        end
        return nil
    end

    local moduleScript = GetEliminationFeedModule()
    if moduleScript then
        local success, FeedModule = pcall(require, moduleScript)
        if success and FeedModule and FeedModule.Play then
            local OldPlay = FeedModule.Play
            
            FeedModule.Play = function(self, victim, eliminator, assistant, weaponName, isCrit, isBlind, isNoscope)
                if eliminator == LocalPlayer then
                    if Toggles.KillSay and Toggles.KillSay.Value then
                        local lang = Options.KillSayLanguage.Value
                        local msgType = Options.KillSayType.Value
                        local msgList = {}
                        
                        if msgType == 'Custom' then
                            msgList = Globals.CustomKillSayMessages or {}
                        elseif MessageTemplates[lang] and MessageTemplates[lang][msgType] then
                            msgList = MessageTemplates[lang][msgType]
                        end

                        if #msgList > 0 then
                            local TextChat = msgList[math.random(1, #msgList)]
                            pcall(function()
                                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(TextChat)
                            end)
                        end
                    end
                end
                return OldPlay(self, victim, eliminator, assistant, weaponName, isCrit, isBlind, isNoscope)
            end
        end
    end
end)
end
