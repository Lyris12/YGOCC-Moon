--Chronologist Ruler, Locrix
--Keddy was here~
local function ID()
    local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
    str=string.sub(str,1,string.len(str)-4)
    local cod=_G[str]
    local id=tonumber(string.sub(str,2))
    return id,cod
end

local id,cod=ID()
function cod.initial_effect(c)
	--Link Summon
    aux.AddLinkProcedure(c,nil,2)
    c:EnableReviveLimit()
	--Rotate Link Arrows
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EVENT_ADJUST)
    e0:SetRange(LOCATION_MZONE)
    e0:SetOperation(cod.tcop)
    c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(cod.lkop)
	c:RegisterEffect(e1)
	--Gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+39507090+id)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return eg:GetFirst()==e:GetHandler() end)
	e2:SetTarget(cod.atktg)
	e2:SetOperation(cod.atkop)
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

--Rotate Link Arrows
function cod.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
	e1:SetValue(ev)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1)
end

--ATK
function cod.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,g:GetCount(),0,500)
end
function cod.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end