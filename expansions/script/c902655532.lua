--Pandemoniumgraph of Eternity
local cid,id=GetID()
function cid.initial_effect(c)
	--You can only control 1 "Pandemoniumgraph of Eternity".
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	c:RegisterEffect(e1)
	--Other "Pandemoniumgraph" cards you control cannot targeted by your opponent's Spell/Trap effects.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(0xcf80) and c~=e:GetHandler() end)
	e2:SetValue(cid.evalue)
	c:RegisterEffect(e2)
	--When you Pandemonium Summon a monster(s) using a "Pandemoniumgraph" card: You can draw 1 card.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetCondition(cid.indcon)
	e3:SetTarget(cid.indtg)
	e3:SetOperation(cid.indop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_COST)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_HAND+LOCATION_EXTRA,0)
	e4:SetLabelObject(e3)
	e4:SetCost(aux.TRUE)
	e4:SetOperation(cid.check)
	c:RegisterEffect(e4)
end
function cid.evalue(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and rp~=e:GetHandlerPlayer()
end
function cid.cfilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsSummonType(SUMMON_TYPE_SPECIAL+726)
end
function cid.indcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter,1,nil,tp)
end
function cid.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.indop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function cid.pafilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM)
		and c:GetTurnID()==Duel.GetTurnCount() and c:GetReason()==REASON_RULE
end
function cid.check(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstMatchingCard(cid.pafilter,tp,LOCATION_EXTRA,0,nil)
	e:GetLabelObject():SetLabelObject(tc)
end
