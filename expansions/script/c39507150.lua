--Chronologist Ruler, Chronos
--Keddy was here~
local function ID()
    local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
    str=string.sub(str,1,string.len(str)-4)
    local cod=_G[str]
    local id=tonumber(string.sub(str,2))
    return id,cod
end
xpcall(function() require("expansions/script/c39507090") end,function() require("script/c39507090") end)

local id,cod=ID()
function cod.initial_effect(c)
    --Link Summon
    aux.AddLinkProcedure(c,nil,2)
    c:EnableReviveLimit()
    --Rotate Link Arrows
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_ADJUST)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(cod.tcop)
    c:RegisterEffect(e1)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EVENT_CUSTOM+id)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(cod.lkop)
    c:RegisterEffect(e3)
    --Destroy
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_CUSTOM+39507090+id)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return eg:GetFirst()==e:GetHandler() end)
    e2:SetTarget(cod.destg)
    e2:SetOperation(cod.desop)
    c:RegisterEffect(e2)
end

--Turn Check
cod.turn={1}

--Link Check
function cod.tcop(e,tp,eg,ep,ev,re,r,rp)
    local t=cod.turn
    local c=e:GetHandler()
    local ct=1
    if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) then
    	local _,eg=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
    	if eg:GetFirst()==c then
    		if Duel.GetTurnCount()~=table.unpack(t) then
    			t[1]=Duel.GetTurnCount()
    		end
    		return
    	elseif eg:IsExists(function (c,ec) return c==ec end,1,nil,c) then
    		if Duel.GetTurnCount()~=table.unpack(t) then
    			t[1]=Duel.GetTurnCount()
    		end
    		return
    	else return false end
    end
    if Duel.GetTurnCount()~=table.unpack(t) then
        if Duel.GetTurnCount()-table.unpack(t)>1 then
            ct=Duel.GetTurnCount()-table.unpack(t)
        end
        t[1]=Duel.GetTurnCount()
        local val=Card.RLinkVal(c,ct)
        return Duel.RaiseEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,val)
    end
end
function cod.lkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
    e1:SetValue(ev)
    e1:SetReset(RESET_EVENT+0x1fe0000)
    c:RegisterEffect(e1)
end
function cod.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),tp,LOCATION_ONFIELD)
end
function cod.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end