--created by Jake, coded by XGlitchy30
--Dawn Blader - Eroko
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(aux.DiscardCost(s.cfilter,1,1,true))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DDD+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DDD)
	e3:SetCode(EVENT_DISCARD)
	e3:HOPT()
	e3:SetCondition(s.dsccond)
	e3:SetTarget(aux.SearchTarget(s.cfilter))
	e3:SetOperation(aux.SearchOperation(s.cfilter))
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(0x613)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if not c:IsSummonableCard() then return false end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetCondition(s.ntcon)
		e1:SetReset(RESET_CHAIN)
		c:RegisterEffect(e1)
		local res=c:IsSummonable(true,nil)
		e1:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsRelateToChain() and c:IsSummonableCard() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetCondition(s.ntcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if c:IsSummonable(true,nil) then
			Duel.Summon(tp,c,true,nil)
		else
			e1:Reset()
		end
	end
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.CheckTribute(c,0)
end
function s.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x613)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,0,c)
	if ct>3 then ct=3 end
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=Duel.GetMatchingGroupCount(s.drfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	if d==0 then return end
	if d>3 then d=3 end
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.dsccond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x613) and (c:IsReason(REASON_EFFECT) or (c:IsReason(REASON_COST) and re:IsActivated()))
end
